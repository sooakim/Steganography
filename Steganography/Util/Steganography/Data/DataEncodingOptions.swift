//
//  DataEncodingOptions.swift
//  Steganography
//
//  Created by 김수아 on 12/4/24.
//

import Foundation

enum DataEncodingOptions {
    case plain
    case encryptWithAES(password: String)
}
