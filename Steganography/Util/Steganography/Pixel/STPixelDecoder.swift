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
    static let shared = Self()

    func decode(image: UIImage, with options: EncryptionOptions) async throws -> String? {
        guard let bitmapBytes = image.bitmapData() else{ throw STPixelDecoderError.decodeImageFailed }

        let messageSizeBits = UInt64.bitWidth
        var messageSizeBitsBuffer: [UInt8] = []
        var messageBinaryBuffer: [UInt8] = []
        var messageBinaryByte: [UInt8] = []
        var messageSize: UInt64? = nil
        var message: String? = nil
        for (index, byte) in bitmapBytes.enumerated() {
//            let pixelIndex = index / 4
            let componentIndex = index % 4
            let blueComponentIndex = 2
            guard componentIndex == blueComponentIndex else { continue }                                                            // blue byte만 필요

            let blueBits = byte.binaryData
            if messageSizeBitsBuffer.count != messageSizeBits {
                messageSizeBitsBuffer.append(contentsOf: blueBits.suffix(2))
                print("==== decoded Message Buffering: \(messageSizeBitsBuffer)")
            } else if messageSize == nil {
                let parsedSize = UInt64(binary: messageSizeBitsBuffer)
                print("==== decoded Message Size: \(messageSize) buffer: \(messageSizeBitsBuffer)")
                if parsedSize == nil || parsedSize == 0 {
                    throw STPixelDecoderError.decodeImageFailed
                }
                messageSize = UInt64(binary: messageSizeBitsBuffer)
            }

            if let _ = messageSize, messageBinaryBuffer.count != 8 {
                messageBinaryBuffer.append(contentsOf: blueBits.suffix(2))
            }

            if let messageSize, messageBinaryBuffer.count == 8, Int(messageSize / 8) != messageBinaryByte.count{
                let buffer = messageBinaryBuffer
                messageBinaryBuffer.removeAll(keepingCapacity: true)

                let parsedByte = UInt8(binary: buffer)
                print("==== decoded Message Byte: \(parsedByte) buffer: \(buffer)")
                if let parsedByte {
                    messageBinaryByte.append(parsedByte)
                } else{
                    throw STPixelDecoderError.decodeImageFailed
                }
            }

            if let messageSize, Int(messageSize / 8) == messageBinaryByte.count {
                let parsedMessage = String(data: Data(messageBinaryByte), encoding: .nonLossyASCII)
                print("==== decoded Message: \(parsedMessage)")
                if let parsedMessage {
                    return parsedMessage
                } else{
                    throw STPixelDecoderError.decodeImageFailed
                }
            }
        }
        return message
    }
}

extension FixedWidthInteger{
    init?(binary: [UInt8]){
        self.init(binary.lazy.map{ String($0) }.joined(separator: ""), radix: 2)
    }
}
