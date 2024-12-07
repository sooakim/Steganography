//
//  STLSBEncoder.swift
//  Steganography
//
//  Created by 김수아 on 11/24/24.
//

import Foundation
import UIKit

protocol STLSBEncodable {
    func encode(
        data: Data,
        with header: STLSBHeader,
        into image: UIImage,
        progressHandler: ((CGFloat) async -> Void)
    ) async throws -> UIImage
}
