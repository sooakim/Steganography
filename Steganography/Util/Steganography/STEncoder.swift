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
    ///   - data: 이미지에 합성할 데이터
    ///   - image: 합성할 원본 이미지
    ///   - progressHandler: 진행상황을 표시하는데 사용할 수 있습니다. (0~1 사이의 값)
    /// - Returns: 합성된 이미지를 반환합니다.
    func encode(
        data: Data,
        with header: STHeader,
        into image: UIImage,
        progressHandler: ((CGFloat) async -> Void)
    ) async throws -> UIImage
}
