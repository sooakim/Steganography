//
//  LSBEncodingFileInputScreen.swift
//  Steganography
//
//  Created by 김수아 on 12/3/24.
//

import Foundation
import SwiftUI

struct LSBEncodingFileInputScreen: View {
    @Binding var importingFile: URL?
    @Binding var password: String
    @State private var isPresenting: Bool = false
    @State private var alertMessage: AlertMessage?

    var body: some View {
        VStack(spacing: 0) {
            Text("""
            이미지에 삽입할 파일을 선택해주세요.
            """)
            .multilineTextAlignment(.leading)
            .font(.title2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

            VStack {
                HStack(spacing: 16) {
                    Image(.icAttachmentFile)
                        .resizable()
                        .frame(width: 44, height: 44)

                    Text("파일을 선택하세요.")

                    Spacer()
                }
                .padding()
                .background{
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(importingFile != nil ? Color(.accent) : Color.gray, lineWidth: 1)
                        .fill(importingFile != nil  ? Color(.lightAccent) : Color.white)
                        .shadow(radius: 1, x: 1, y: 1)
                }
                .onTapGesture {
                    isPresenting = true
                }
                .padding()
                .fileImporter(isPresented: $isPresenting, allowedContentTypes: [.item], onCompletion: { result in
                    switch result {
                    case let .success(url):
                        importingFile = url
                    case .failure:
                        alertMessage = AlertMessage(message: "파일을 불러올 수 없습니다.")
                    }
                })
                .alert(item: $alertMessage) { message in
                    Alert(
                        title: Text(message.title),
                        message: Text(message.message)
                   )
                }

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

private extension LSBEncodingFileInputScreen {
    struct AlertMessage: Identifiable {
        let id = UUID().uuidString
        let title = "알림"
        let message: String
    }
}

#Preview{
    LSBEncodingFileInputScreen(importingFile: .constant(nil), password: .constant(""))
}
