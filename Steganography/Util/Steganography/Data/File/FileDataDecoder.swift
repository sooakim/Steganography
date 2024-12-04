//
//  FileDataDecoder.swift
//  Steganography
//
//  Created by 김수아 on 12/4/24.
//

import Foundation
import CryptoSwift

struct FileDataDecoder: DataDecodable {
    static let shared = FileDataDecoder()

    func decode(_ data: Data, options: DataEncodingOptions) throws -> URL? {
        let tempFileName = UUID().uuidString
        let directory = URL.temporaryDirectory.appendingPathComponent("output")
        if !FileManager.default.fileExists(atPath: directory.absoluteString) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        let tempURL = directory.appendingPathComponent(tempFileName + ".txt")

        switch options {
        case .plain:
            try data.write(to: tempURL)
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
            try Data(decryptedBytes).write(to: tempURL)
        }
        return tempURL
    }
}
