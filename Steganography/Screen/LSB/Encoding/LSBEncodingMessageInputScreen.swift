//
//  LSBEncodingMessageInputScreen.swift
//  Steganography
//
//  Created by 김수아 on 12/3/24.
//

import SwiftUI

struct LSBEncodingMessageInputScreen: View {
    @Binding var message: String
    @Binding var password: String

    var body: some View {
        VStack(spacing: 0) {
            Text("""
            이미지에 삽입할 메시지를 입력해주세요.
            """)
            .multilineTextAlignment(.leading)
            .font(.title2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

            VStack {
                TextField(text: $message) {
                    Text("삽입할 메시지")
                        .foregroundStyle(Color.gray)
                }
                .styledTextField()
                .padding()

                TextField(text: $password) {
                    Text("메시지 암호화를 위한 비밀번호")
                        .foregroundStyle(Color.gray)
                }
                .styledTextField()
                .padding()
            }.frame(maxHeight: .infinity)
        }
    }
}

#Preview {
    LSBEncodingMessageInputScreen(
        message: .constant(""),
        password: .constant("")
    )
}
