//
//  FileDataEncoder.swift
//  Steganography
//
//  Created by 김수아 on 12/4/24.
//

import Foundation
import CryptoSwift

struct FileDataEncoder: DataEncodable {
    static let shared = FileDataEncoder()

    func encode(_ data: URL, options: DataEncodingOptions) throws -> Data? {
        guard data.startAccessingSecurityScopedResource() else{ return nil }
        defer { data.stopAccessingSecurityScopedResource() }

        let encodedData: Data
        switch options {
        case .plain:
            let fileData = try Data(contentsOf: data)
            encodedData = fileData
        case let .encryptWithAES(password):
            guard let passwordData = password.data(using: .utf8) else { return nil }
            let fileData = try Data(contentsOf: data)

            let key = try PKCS5.PBKDF2(
                password: passwordData.bytes,
                salt: "Steganography".data(using: .utf8)!.bytes,
                keyLength: 256 / 8,
                variant: .sha3(.sha256)
            ).calculate()
            let randomIV = AES.randomIV(AES.blockSize)
            let aes = try AES(key: key, blockMode: CBC(iv: randomIV), padding: .pkcs5)
            guard let encryptedBytes = try? aes.encrypt(fileData.bytes) else { return nil }
            encodedData = Data(randomIV + encryptedBytes)
        }
        return encodedData
    }
}
