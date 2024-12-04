//
//  STDecoder.swift
//  Steganography
//
//  Created by 김수아 on 11/24/24.
//

import UIKit

protocol STDecodable {
    /// 스테가노그래피 기법을 적용한 이미지에서 원문 메시지를 찾습니다.
    /// 원문을 찾을 수 없거나 복호화에 실패한 경우 에러가 발생합니다.
    /// - Parameters:
    ///   - image: 합성된 이미지
    /// - Returns: 합성된 이미지에서 원문 메시지를 찾아 반환합니다.
    func decode(
        image: UIImage,
        progressHandler: ((CGFloat) async -> Void)
    ) async throws -> Data?

    func decodeHeader(
        image: UIImage
    ) async throws -> STHeader?
}
