//
//  StringEncoder.swift
//  Steganography
//
//  Created by 김수아 on 11/26/24.
//

import Foundation
import CryptoSwift

struct StringEncoder: DataEncodable {
    static let shared = StringEncoder()

    func encode(_ data: String, options: DataEncodingOptions) -> Data? {
        let encodedData: Data
        switch options {
        case .plain:
            guard let messageData = data.data(using: .nonLossyASCII) else{ return nil }
            encodedData = messageData
        case let .encryptWithAES(password):
            guard let passwordData = password.data(using: .nonLossyASCII) else { return nil }
            guard let messageData = data.data(using: .nonLossyASCII) else { return nil }

            let randomIV = AES.randomIV(AES.blockSize)
            guard let aes = try? AES(key: passwordData.bytes, blockMode: CBC(iv: randomIV), padding: .pkcs7) else { return nil }
            guard let encryptedBytes = try? aes.encrypt(messageData.bytes) else { return nil }
            encodedData = Data(encryptedBytes)
        }
        return encodedData
    }
}
