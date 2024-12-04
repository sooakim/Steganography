//
//  DataEncoder.swift
//  Steganography
//
//  Created by 김수아 on 11/26/24.
//

import Foundation

protocol DataEncodable {
    associatedtype Input

    func encode(_ data: Input, options: DataEncodingOptions) throws -> Data?
}
