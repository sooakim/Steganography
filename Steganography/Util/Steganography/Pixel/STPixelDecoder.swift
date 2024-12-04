//
//  STPixelDecoder.swift
//  Steganography
//
//  Created by 김수아 on 11/24/24.
//

import UIKit

enum STPixelDecoderError: Error {
    case invalidPassword
    case imageTooSmall
    case decodeImageFailed
    case encodeImageFailed
}


struct STPixelDecoder : STDecodable {
    static let shared = STPixelDecoder()

    enum DecodingStep {
    case header
    case messageSize
    case message
    }

    func decode(
        image: UIImage,
        progressHandler: ((CGFloat) async -> Void) = { _ in }
    ) async throws -> Data? {
        guard let bitmapBytes = image.bitmapData() else{ throw STPixelDecoderError.decodeImageFailed }

        let headerBitsSize = UInt16.bitWidth
        let messageSizeBitsSize = UInt64.bitWidth
        var messageSizeBitsBuffer: [UInt8] = []
        var messageBitsBuffer: [UInt8] = []
        var messageByteBuffer: [UInt8] = []
        var messageBitsSize: UInt64 = 0
        var messageByteSize: UInt64 = 0
        var decodingStep: DecodingStep = .header

        for (index, byte) in bitmapBytes.enumerated() {
            try Task.checkCancellation()
            await Task.yield()

            let pixelIndex = index / 4
            let componentIndex = index % 4
            let blueComponentIndex = 2
            guard componentIndex == blueComponentIndex else { continue }                                                            // blue byte만 필요

            let blueBits = byte.binaryBitsData
            print("pixel index", index / 4, blueBits.suffix(2).map{ String($0) }.joined())

            // skip header

            // headerBitsSize / 2 == 8bits
            if case .header = decodingStep, pixelIndex == headerBitsSize / 2 - 1 {
                decodingStep = .messageSize
                print("skip header")
                continue
            }

            if case .messageSize = decodingStep, messageSizeBitsBuffer.count != messageSizeBitsSize {
                let blueBits = byte.binaryBitsData
                messageSizeBitsBuffer.append(contentsOf: blueBits.suffix(2))
            }

            if case .messageSize = decodingStep, messageSizeBitsBuffer.count == messageSizeBitsSize{
                guard let parsedSize = UInt64(binary: messageSizeBitsBuffer), parsedSize > 0 else {
                    throw STPixelDecoderError.decodeImageFailed
                }
                messageBitsSize = parsedSize
                messageByteSize = parsedSize / 8
                decodingStep = .message
                continue
            }

            if case .message = decodingStep, messageByteBuffer.count != messageByteSize, messageBitsBuffer.count != 8 {
                let blueBits = byte.binaryData
                messageBitsBuffer.append(contentsOf: blueBits.suffix(2))
            }

            if case .message = decodingStep, messageByteBuffer.count != messageByteSize, messageBitsBuffer.count == 8 {
                let bitsBuffer = messageBitsBuffer
                messageBitsBuffer.removeAll(keepingCapacity: true)

                guard let parsedByte = UInt8(binary: bitsBuffer) else { throw STPixelDecoderError.decodeImageFailed }
                messageByteBuffer.append(parsedByte)
            }

            if case .message = decodingStep, messageByteBuffer.count == messageByteSize {
                return Data(messageByteBuffer)
            }

            await progressHandler(CGFloat(index) / CGFloat(bitmapBytes.count) * 100)
        }
        return nil
    }

    func decodeHeader(image: UIImage) async throws -> STHeader? {
        guard let bitmapBytes = image.bitmapData() else{ throw STPixelDecoderError.decodeImageFailed }

        let headerBitsSize = UInt16.bitWidth
        var headerBitsBuffer: [UInt8] = []
        for (index, byte) in bitmapBytes.enumerated() {
            try Task.checkCancellation()
            await Task.yield()

            let componentIndex = index % 4
            let blueComponentIndex = 2
            guard componentIndex == blueComponentIndex else { continue }

            let blueBits = byte.binaryBitsData
            headerBitsBuffer.append(contentsOf: blueBits.suffix(2))

            if headerBitsBuffer.count == headerBitsSize {
                guard let headerValue = UInt16(binary: headerBitsBuffer) else{ throw STPixelDecoderError.decodeImageFailed }
                return STHeader(rawValue: headerValue)
            }
        }
        return nil
    }
}

extension FixedWidthInteger{
    init?(binary: [UInt8]){
        self.init(binary.lazy.map{ String($0) }.joined(separator: ""), radix: 2)
    }
}
