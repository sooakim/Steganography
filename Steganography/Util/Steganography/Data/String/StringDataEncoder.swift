//
//  StringEncoder.swift
//  Steganography
//
//  Created by 김수아 on 11/26/24.
//

import Foundation
import CryptoSwift

struct StringDataEncoder: DataEncodable {
    static let shared = StringDataEncoder()

    func encode(_ data: String, options: DataEncodingOptions) throws -> Data? {
        let encodedData: Data
        switch options {
        case .plain:
            guard let messageData = data.data(using: .utf8) else{ return nil }
            encodedData = messageData
        case let .encryptWithAES(password):
            guard let passwordData = password.data(using: .utf8) else { return nil }
            guard let messageData = data.data(using: .utf8) else { return nil }

            let key = try PKCS5.PBKDF2(
                password: passwordData.bytes,
                salt: "Steganography".data(using: .utf8)!.bytes,
                keyLength: 256 / 8,
                variant: .sha3(.sha256)
            ).calculate()
            let randomIV = AES.randomIV(AES.blockSize)
            let aes = try AES(key: key, blockMode: CBC(iv: randomIV), padding: .pkcs7)
            let encryptedBytes = try aes.encrypt(messageData.bytes)
            encodedData = Data(randomIV + encryptedBytes)
        }
        return encodedData
    }
}
