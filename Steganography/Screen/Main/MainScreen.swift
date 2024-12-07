//
//  MainScreen.swift
//  Steganography
//
//  Created by 김수아 on 12/3/24.
//

import SwiftUI

enum WorkCategory: Int {
    case lsbEncoding
    case lsbDecoding
    case fileMergeEncoding
    case fileMergeDecoding
}

struct MainScreen: View {
    @Binding var selectedWorkCategory: WorkCategory?
    private let questions: [Question] = [
        Question(
            id: WorkCategory.lsbEncoding,
            iconResource: .icPhoto,
            title: "PNG LSB 인코딩"
        ),
        Question(
            id: WorkCategory.lsbDecoding,
            iconResource: .icPhoto,
            title: "PNG LSB 디코딩"
        ),
//        Question(
//            id: WorkCategory.fileMergeEncoding,
//            iconResource: .icMerge,
//            title: "파일 머지 인코딩"
//        ),
//        Question(
//            id: WorkCategory.fileMergeDecoding,
//            iconResource: .icMerge,
//            title: "파일 머지 디코딩"
//        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            Text("""
            원하는 작업을 선택하세요.
            """)
            .multilineTextAlignment(.leading)
            .font(.title2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

            QuestionList(
                questions: questions,
                selectedWorkCategory: $selectedWorkCategory,
                didTapQuestion: nil
            )
        }
    }
}

#Preview{
    MainScreen(selectedWorkCategory: .constant(nil))
}
