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

struct STPixelEncoder: STLSBEncodable {
    static let shared = STPixelEncoder()

    private init() {}

    func encode(
        data: Data,
        with header: STLSBHeader,
        into image: UIImage,
        progressHandler: ((CGFloat) async -> Void) = { _ in }
    ) async throws -> UIImage {
        let messageToEncode = data
        let messageBits = messageToEncode.bitsCount
        let headerBits = UInt16.bitWidth
        let messageSizeBits = UInt64.bitWidth
        let requiredBits = headerBits + messageSizeBits + messageBits
        let modulationBitsPerPixel = 2
        let requiredModulationPixels = requiredBits / modulationBitsPerPixel
        
        let imagePixels = image.pixelWidth * image.pixelHeight
        guard imagePixels >= CGFloat(requiredModulationPixels) else { throw STPixelEncoderError.imageTooSmall }                     //필요한 픽셀수보다 이미지의 픽셀수가 작다면, 인코딩 불가

        var encodedData: [UInt8] = []                                                                                               //최종적으로 숨길 데이터를 binary로 인코딩해 합침
        let encodedHeader = header.rawValue.binaryBitsData
        encodedData.append(contentsOf: encodedHeader)
        let encodedMessageSize = UInt64(messageBits).binaryBitsData
        encodedData.append(contentsOf: encodedMessageSize)
        encodedData.append(contentsOf: messageToEncode.binaryData())

        guard var bitmapBytes = image.rotatedImage().bitmapData()?.bytes else{ throw STPixelEncoderError.decodeImageFailed }
        var progress: CGFloat = 0
        for index in (0..<requiredModulationPixels) {
            try Task.checkCancellation()

            let blueComponentIndex = 2
            let currentBlueByteIndex = index * 4 + blueComponentIndex
            var blueBits = bitmapBytes[currentBlueByteIndex].binaryBitsData
            blueBits[blueBits.count - 2] = encodedData[index * 2]
            blueBits[blueBits.count - 1] = encodedData[index * 2 + 1]
            let blueByte = UInt8(blueBits.map(String.init).joined(), radix: 2)!
            bitmapBytes[currentBlueByteIndex] = blueByte

            progress = max(0, min(1, CGFloat(index) / CGFloat(requiredModulationPixels)))
            await progressHandler(progress)
        }

        let width = Int(image.pixelWidth)
        let height = Int(image.pixelHeight)
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
