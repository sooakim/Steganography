//
//  ContentView.swift
//  Steganography
//
//  Created by lisa.kim on 11/13/24.
//
//

import PhotosUI
import SwiftUI
import UIKit

struct ContentView: View {
    @State private var isPresenting: Bool = false
    @State private var pickedItem: PhotosPickerItem?
    @State private var pickedImage: UIImage?

    @State private var message: String = ""
    @State private var password: String = ""

    private let cancellableBag = CancellableBag()

    var body: some View {
        GeometryReader { geometryProxy in
            ZStack {
                if let pickedImage {
                    Image(uiImage: pickedImage)
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 8)
                        .frame(width: geometryProxy.size.width)
                        .ignoresSafeArea()
                }else{
                    Color.clear
                        .ignoresSafeArea()
                }

                VStack {
                    Text("Image Steganography")
                        .font(.title)
                        .fontWeight(.semibold)

                    LabeledContent {
                        TextField(text: $message) {
                            Text("message to hide")
                        }.textFieldStyle(.roundedBorder)
                    } label: {
                        Text("Message: ")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    LabeledContent {
                        TextField(text: $password) {
                            Text("password for encryption")
                        }.textFieldStyle(.roundedBorder)
                    } label: {
                        Text("Password: ")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    Button {
                        isPresenting = true
                    } label: {
                        Text("Select Original Image")
                    }.buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .overlay(alignment: .bottom) {
                Button {
                    Task { @MainActor in
                        guard let pickedImage else{ return }
                        let encoder: STEncodable = STPixelEncoder.shared
                        do {
                            guard let encodedString = StringEncoder.shared.encode(message, options: .plain) else{ return }
                            let outputImage = try await encoder.encode(
                                data: encodedString,
                                into: pickedImage
                            ) { progress in
                                print("====", progress)
                            }
                            UIImageWriteToSavedPhotosAlbum(outputImage, nil, nil, nil)
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    Text("Encode")
                        .frame(maxWidth: .infinity, minHeight: 32)
                }
                .padding(.init(top: 16, leading: 32, bottom: 16, trailing: 32))
                .buttonStyle(.borderedProminent)
            }
            .onChange(of: pickedItem, { oldValue, newValue in
                guard oldValue != newValue else { return }
                guard let pickedItem = newValue else { return }
                cancellableBag.cancel()
                Task {
                    pickedImage = nil
                    do {
                        guard let data = try await pickedItem.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) else { return }
                        pickedImage = uiImage
                    } catch {
                        print(error)
                    }
                }.add(to: cancellableBag)
            })
            .photosPicker(isPresented: $isPresenting, selection: $pickedItem)
        }
    }
}

#Preview {
    ContentView()
}
