//
//  DataDecoder.swift
//  Steganography
//
//  Created by 김수아 on 12/4/24.
//

import Foundation

protocol DataDecodable {
    associatedtype Output

    func decode(_ data: Data, options: DataEncodingOptions) throws -> Output?
}
