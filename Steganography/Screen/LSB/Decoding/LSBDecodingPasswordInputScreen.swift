//
//  LSBDecodingPasswordInputScreen.swift
//  Steganography
//
//  Created by 김수아 on 12/4/24.
//

import Foundation
import SwiftUI

struct LSBDecodingPasswordInputScreen: View {
    @Binding var password: String

    var body: some View {
        VStack(spacing: 0) {
            Text("""
            복호화를 위한 비밀번호를 입력하세요.
            """)
            .multilineTextAlignment(.leading)
            .font(.title2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

            VStack {
                TextField(text: $password) {
                    Text("메시지 복호화를 위한 비밀번호")
                        .foregroundStyle(Color.gray)
                }
                .styledTextField()
                .padding()
            }.frame(maxHeight: .infinity)
        }
    }
}

#Preview {
    LSBDecodingPasswordInputScreen(password: .constant(""))
}
