//
//  STEncoder.swift
//  Steganography
//
//  Created by 김수아 on 11/24/24.
//

import Foundation
import UIKit

protocol STEncodable {
    /// 스테가노그래피 기법을 적용한 이미지를 생성합니다.
    /// - Parameters:
    ///   - message: 이미지에 합성할 원문 메시지
    ///   - image: 합성할 원본 이미지
    ///   - options: 메시지 암호화 관련 옵션
    /// - Returns: 합성된 이미지를 반환합니다.
    func encode(
        message: String,
        into image: UIImage,
        with options: EncryptionOptions,
        progressHandler: ((CGFloat) async -> Void)
    ) async throws -> UIImage
}
