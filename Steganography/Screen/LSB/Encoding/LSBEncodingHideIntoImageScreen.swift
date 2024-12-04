//
//  LSBEncodingHideIntoImageScreen.swift
//  Steganography
//
//  Created by 김수아 on 12/3/24.
//

import SwiftUI
import PhotosUI

struct LSBEncodingHideIntoImageScreen: View {
    @Binding var selectedImage: UIImage?
    @State private var isPresenting: Bool = false
    @State private var pickedItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 0) {
            Text("""
            사용할 이미지를 선택해주세요.
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

                    Text("이미지를 선택해주세요")

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
                    isPresenting = true
                }
                .padding()
                .photosPicker(isPresented: $isPresenting, selection: $pickedItem)
                .photosPickerStyle(.presentation)
                .onChange(of: pickedItem) { pickedItem in
                    Task {
                        do{
                            guard
                                let pickedItem,
                                let imageData = try await pickedItem.loadTransferable(type: Data.self),
                                let image = UIImage(data: imageData)
                            else{
                                print("empty")
                                self.selectedImage = nil
                                return
                            }

                            print("selectedImage")
                            selectedImage = image
                        }catch{
                            selectedImage = nil
                            print(error)
                        }
                    }
                }
            }.frame(maxHeight: .infinity)
        }
    }
}

#Preview {
    LSBEncodingHideIntoImageScreen(
        selectedImage: .constant(nil)
    )
}
