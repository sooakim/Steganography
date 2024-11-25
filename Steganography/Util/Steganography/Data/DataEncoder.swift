//
//  DataEncoder.swift
//  Steganography
//
//  Created by 김수아 on 11/26/24.
//

import Foundation

enum DataEncodingOptions {
    case plain
    case encryptWithAES(password: String)
}

protocol DataEncodable {
    associatedtype Input

    func encode(_ data: Input, options: DataEncodingOptions) -> Data?
}
