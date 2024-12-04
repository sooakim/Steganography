//
//  StringDataDecoder.swift
//  Steganography
//
//  Created by 김수아 on 12/4/24.
//

import Foundation
import CryptoSwift

struct StringDataDecoder: DataDecodable {
    static let shared = StringDataDecoder()

    func decode(_ data: Data, options: DataEncodingOptions) throws -> String? {
        let decodedString: String
        switch options {
        case .plain:
            guard let message = String(data: data, encoding: .utf8) else{ return nil }
            decodedString = message
        case let .encryptWithAES(password):
            guard let passwordData = password.data(using: .utf8) else { return nil }
            let cipherData = data

            let key = try PKCS5.PBKDF2(
                password: passwordData.bytes,
                salt: "Steganography".data(using: .utf8)!.bytes,
                keyLength: 256 / 8,
                variant: .sha3(.sha256)
            ).calculate()
            let randomIV = Array(cipherData.bytes.prefix(AES.blockSize))
            let aes = try AES(key: key, blockMode: CBC(iv: randomIV), padding: .pkcs7)
            let decryptedBytes = try aes.decrypt(cipherData.bytes.suffix(cipherData.count - AES.blockSize))
            guard let message = String(data: Data(decryptedBytes), encoding: .utf8) else { return nil }
            decodedString = message
        }
        return decodedString
    }
}
