//
//  STPixelEncoder.swift
//  Steganography
//
//  Created by 김수아 on 11/24/24.
//

import UIKit
import CryptoSwift

enum STPixelEncoderError: Error {
    case invalidPassword
    case imageTooSmall
    case decodeImageFailed
    case encodeImageFailed
}

struct STPixelEncoder: STEncodable {
    static let shared = STPixelEncoder()

    private init() {}

    func encode(
        data: Data,
        into image: UIImage,
        progressHandler: ((CGFloat) async -> Void) = { _ in }
    ) async throws -> UIImage {
        let messageToEncode = data
        let messageBits = messageToEncode.bitsCount
        let headerBits = 0 //UInt16.bitWidth
        let messageSizeBits = UInt64.bitWidth
        let requiredBits = headerBits + messageSizeBits + messageBits
        let modulationBitsPerPixel = 2
        let requiredModulationPixels = requiredBits / modulationBitsPerPixel
        
        let imagePixels = image.pixelWidth * image.pixelHeight
        guard imagePixels >= CGFloat(requiredModulationPixels) else { throw STPixelEncoderError.imageTooSmall }                     //필요한 픽셀수보다 이미지의 픽셀수가 작다면, 인코딩 불가

        var encodedData: [UInt8] = []                                                                                               //최종적으로 숨길 데이터를 binary로 인코딩해 합침
//        let encodedHeader = UInt16(options.header().rawValue).binaryData
//        encodedData.append(contentsOf: encodedHeader)
        let encodedMessageSize = UInt64(messageBits).binaryData
        encodedData.append(contentsOf: encodedMessageSize)
        encodedData.append(contentsOf: messageToEncode.binaryData())

        guard var bitmapBytes = image.rotatedImage().bitmapData()?.bytes else{ throw STPixelEncoderError.decodeImageFailed }
        var progress: CGFloat = 0
        for index in (0..<requiredModulationPixels) {
            try Task.checkCancellation()
            let blueComponentIndex = 2
            let currentBlueByteIndex = index * 4 + blueComponentIndex
            var blueBits = bitmapBytes[currentBlueByteIndex].binaryData
            blueBits[blueBits.count - 2] = encodedData[index * 2]
            blueBits[blueBits.count - 1] = encodedData[index * 2 + 1]
            let blueByte = UInt8(blueBits.map(String.init).joined(), radix: 2)!
            bitmapBytes[currentBlueByteIndex] = blueByte

            progress = max(0, min(1, CGFloat(index) / CGFloat(requiredModulationPixels)))
            await progressHandler(progress)
        }

        let width = Int(image.size.width)
        let height = Int(image.size.height)
        let bitsPerComponent = UInt8.bitWidth
        let bytePerPixel = 4                                                                                                        // RGBA
        let bytesPerRow = width * bytePerPixel
        let context = CGContext(
            data: &bitmapBytes,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        guard let cgImage = context?.makeImage() else{ throw STPixelEncoderError.encodeImageFailed }
        return UIImage(cgImage: cgImage)
    }
}

private extension STPixelEncoder {
    struct Header: OptionSet {
        static let message = Self(rawValue: 1 << 0)
        static let encryptedMessage = Self(rawValue: 1 << 1)
        
        fileprivate init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        fileprivate let rawValue: Int
    }
}

private extension EncryptionOptions {
    func header() -> STPixelEncoder.Header {
        var header: STPixelEncoder.Header = [.message]
        switch self {
        case .encryptWithAES:
            header.insert(.encryptedMessage)
        case .plain:
            break
        }
        return header
    }
}

