//
//  FixedWithInteger+.swift
//  Steganography
//
//  Created by 김수아 on 11/26/24.
//

import Foundation

extension FixedWidthInteger {
    var binaryData: Data {
        var binary: [UInt8] = []
        var number = self
        for _ in (0..<bitWidth) {
            binary.insert(UInt8(number & 1), at: 0)
            number >>= 1
        }
        return Data(binary)
    }
}
