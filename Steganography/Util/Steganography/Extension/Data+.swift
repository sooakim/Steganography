//
//  Data+.swift
//  Steganography
//
//  Created by 김수아 on 11/28/24.
//

import Foundation

extension Data {
    var bitsCount: Int {
        let bitPerByte = 8
        return count * bitPerByte
    }

    func binaryData() -> Data {
        Data(self.bytes.flatMap{ $0.binaryData })
    }
}
