//
//  LSBEncodingExportScreen.swift
//  Steganography
//
//  Created by 김수아 on 12/3/24.
//

import SwiftUI

struct LSBEncodingExportScreen: View {
    @Binding var selectedImage: UIImage?
    @State private var alertMessage: AlertMessage?

    var body: some View {
        VStack(spacing: 0) {
            Text("""
            모든 절차가 완료되었습니다!
            """)
            .multilineTextAlignment(.leading)
            .font(.title2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

            VStack {
                HStack(spacing: 16) {
                    if let selectedImage {
                        Image.init(uiImage: selectedImage)
                            .resizable()
                            .frame(width: 44, height: 44)
                    } else {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 44, height: 44)
                    }

                    Text("사진 라이브러리에 추가")

                    Spacer()
                }
                .padding()
                .background{
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(selectedImage != nil ? Color(.accent) : Color.gray, lineWidth: 1)
                        .fill(selectedImage != nil  ? Color(.lightAccent) : Color.white)
                        .shadow(radius: 1, x: 1, y: 1)
                }
                .onTapGesture {
                    guard let selectedImage else { return }
                    UIImageWriteToSavedPhotosAlbum(selectedImage, nil, nil, nil)
                    alertMessage = AlertMessage(message: "사진 라이브러리에 추가되었습니다.")
                }
                .padding()
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

private extension LSBEncodingExportScreen {
    struct AlertMessage: Identifiable {
        let id = UUID().uuidString
        let title = "알림"
        let message: String
    }
}

#Preview {
    LSBEncodingExportScreen(selectedImage: .constant(nil))
}
