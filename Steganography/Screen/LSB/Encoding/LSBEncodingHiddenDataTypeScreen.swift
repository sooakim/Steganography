//
//  LSBEncodingHiddenDataTypeScreen.swift
//  Steganography
//
//  Created by 김수아 on 12/3/24.
//

import SwiftUI

enum LSBAttachmentType {
    case text
    case file
}

struct LSBEncodingHiddenDataTypeScreen: View {
    @Binding var selectedAttachmentType: LSBAttachmentType?

    private let questions = [
        Question(
            id: LSBAttachmentType.text,
            iconResource: .icAttachmentText,
            title: "메시지"
        ),
        Question(
            id: LSBAttachmentType.file,
            iconResource: .icAttachmentFile,
            title: "파일"
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            Text("""
            이미지에 삽입할 데이터 타입을 선택하세요.
            """)
            .multilineTextAlignment(.leading)
            .font(.title2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

            QuestionList(
                questions: questions,
                selectedWorkCategory: $selectedAttachmentType,
                didTapQuestion: nil
            )
        }
    }
}

#Preview {
    LSBEncodingHiddenDataTypeScreen(
        selectedAttachmentType: .constant(nil)
    )
}
