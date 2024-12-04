//
//  LSBDecodingMessageScreen.swift
//  Steganography
//
//  Created by 김수아 on 12/4/24.
//

import Foundation
import SwiftUI

struct LSBDecodingMessageScreen: View {
    @Binding var message: String

    var body: some View {
        VStack(spacing: 0) {
            Text("""
            숨겨진 메시지를 확인하세요.
            """)
            .multilineTextAlignment(.leading)
            .font(.title2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

            VStack {
                Text(message)
                    .multilineTextAlignment(.leading)
                    .padding()
                    .styledTextField()
                    .foregroundStyle(Color.gray)
            }.frame(maxHeight: .infinity)
        }
    }
}

#Preview {
    LSBDecodingMessageScreen(message: .constant("""
    복호화된 메시지입니다.
    복호화된 메시지입니다.
    복호화된 메시지입니다.
    """))
}
