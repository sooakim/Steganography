//
//  StringEncoderTests.swift
//  Steganography
//
//  Created by 김수아 on 11/26/24.
//

import Testing
@testable import Steganography

struct StringEncoderTests {

    @Test func decimalToBinaryTest() {
        let encoder = StringEncoder()
        let data = "Hello World!"
        let actual = encoder.encode(data, options: .plain)?.bytes
        let expect: [UInt8] = [
            UInt8(72),                                                                                                              // H
            UInt8(101),                                                                                                             // e
            UInt8(108),                                                                                                             // l
            UInt8(108),                                                                                                             // l
            UInt8(111),                                                                                                             // o
            UInt8(32),                                                                                                              // (space)
            UInt8(87),                                                                                                              // W
            UInt8(111),                                                                                                             // o
            UInt8(114),                                                                                                             // r
            UInt8(108),                                                                                                             // l
            UInt8(100),                                                                                                             // d
            UInt8(33)                                                                                                               // !
        ]
        #expect(actual == expect)
    }
}

