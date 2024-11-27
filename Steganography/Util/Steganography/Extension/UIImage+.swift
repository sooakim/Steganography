//
//  UIImage+.swift
//  Steganography
//
//  Created by 김수아 on 11/28/24.
//

import UIKit

extension UIImage {
    var pixelHeight: CGFloat {
        self.size.height * self.scale
    }

    var pixelWidth: CGFloat {
        self.size.width * self.scale
    }

    func rotatedImage() -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: pixelWidth, height: pixelHeight)).image { _ in
            self.draw(at: .zero)
        }
    }

    func bitmapData() -> Data? {
        guard let cgImage = self.cgImage else{ return nil }
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        let bitsPerComponent = UInt8.bitWidth
        let bytePerPixel = 4                                                                                                        // RGBA
        let bytesPerRow = width * bytePerPixel
        var data = [UInt8](repeating: 0, count: bytesPerRow * height)
        guard let context = CGContext(
            data: &data,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: width * bytePerPixel,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        return Data(data)
    }
}
