//
//  FixedWidthInteger+.swift
//  Steganography
//
//  Created by 김수아 on 11/26/24.
//

import Testing
@testable import Steganography

struct FixedWidthIntegerTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    @Test func decimalToBinaryTest() {
        #expect(UInt32(10).binaryData.bytes == [
            UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
            UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
            UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
            UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(1), UInt8(0), UInt8(1), UInt8(0)
        ])
    }
}

