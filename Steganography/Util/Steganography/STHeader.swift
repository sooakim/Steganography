//
//  STHeader.swift
//  Steganography
//
//  Created by 김수아 on 11/24/24.
//

struct STHeader: OptionSet{
    static let encryptWithAES256 = Self(rawValue: 1 << 0)
    static let text = Self(rawValue: 1 << 1)
    static let file = Self(rawValue: 1 << 2)

    init(rawValue: UInt16) {
        self.rawValue = rawValue
    }

    let rawValue: UInt16
}

extension STHeader{
    static func +(lhs: Self, rhs: Self) -> Self {
        var new = lhs
        new.insert(rhs)
        return new
    }

    static func +=(acc: inout Self, rhs: Self) {
        acc = acc + rhs
    }
}

extension DataEncodingOptions {
    func asHeader() -> STHeader {
        var header: STHeader = []
        switch self {
        case .plain:
            break
        case .encryptWithAES:
            header.insert(.encryptWithAES256)
        }
        return header
    }
}
