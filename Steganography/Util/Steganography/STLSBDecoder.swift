//
//  STLSBDecoder.swift
//  Steganography
//
//  Created by 김수아 on 11/24/24.
//

import UIKit

protocol STLSBDecodable {

    func decode(
        image: UIImage,
        progressHandler: ((CGFloat) async -> Void)
    ) async throws -> Data?

    func decodeHeader(
        image: UIImage
    ) async throws -> STLSBHeader?
}
