//
//  LSBDecodingFileScreen.swift
//  Steganography
//
//  Created by 김수아 on 12/4/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct LSBDecodingFileScreen: View {
    @Binding var exportingFile: ExportingFile?
    @State private var isPresenting: Bool = false
    @State private var alertMessage: AlertMessage?

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
                HStack(spacing: 16) {
                    Image(.icAttachmentFile)
                        .resizable()
                        .frame(width: 44, height: 44)

                    Text("파일을 확인하세요.")

                    Spacer()
                }
                .padding()
                .background{
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(exportingFile != nil ? Color(.accent) : Color.gray, lineWidth: 1)
                        .fill(exportingFile != nil  ? Color(.lightAccent) : Color.white)
                        .shadow(radius: 1, x: 1, y: 1)
                }
                .onTapGesture {
                    isPresenting = true
                }
                .padding()
                .fileExporter(isPresented: $isPresenting, document: exportingFile, onCompletion: { result in
                    switch result {
                    case .success:
                        alertMessage = AlertMessage(message: "성공적으로 저장했습니다!")
                    case .failure:
                        alertMessage = AlertMessage(message: "저장에 실패했습니다.")
                    }
                })
                .alert(item: $alertMessage) { message in
                    Alert(
                        title: Text(message.title),
                        message: Text(message.message)
                   )
                }
            }.frame(maxHeight: .infinity)
        }
    }
}

private extension LSBDecodingFileScreen {
    struct AlertMessage: Identifiable {
        let id = UUID().uuidString
        let title = "알림"
        let message: String
    }
}

#Preview {
    LSBDecodingFileScreen(exportingFile: .constant(nil))
}
