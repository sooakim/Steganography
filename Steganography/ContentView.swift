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

struct ContentView : View {
    @State private var navigationPath: NavigationPath = .init()
    @State private var footerHeight: CGFloat = 0
    @State private var selectedWorkCategory: WorkCategory?
    @State private var isNextButtonLoading: Bool = false
    @ObservedObject private var lsbEncodingViewModel = LSBEncodingViewModel()
    @ObservedObject private var lsbDecodingViewModel = LSBDecodingViewModel()
    private let cancellableBag = CancellableBag()

    private var progress: CGFloat {
        switch selectedWorkCategory {
        case .lsbEncoding:
            CGFloat(lsbEncodingViewModel.navigationSteps.count) / CGFloat(LSBEncodingNavigationStep.allCases.count)
        case .lsbDecoding:
            CGFloat(lsbDecodingViewModel.navigationSteps.count) / CGFloat(LSBDecodingNavigationStep.allCases.count)
        case .fileMergeEncoding:
            0
        case .fileMergeDecoding:
            0
        case nil:
            0
        }
    }

    var body: some View {
        NavigationStack(path: $navigationPath){
            MainScreen(selectedWorkCategory: $selectedWorkCategory)
                .navigationDestination(for: LSBEncodingNavigationStep.self) { encodingStep in
                    Group{
                        encodingStep.body(viewModel: lsbEncodingViewModel)
                    }
                    .navigationBarBackButtonHidden()
                    .navigationBarHidden(true)
                }
                .navigationDestination(for: LSBDecodingNavigationStep.self) { decodingStep in
                    Group{
                        decodingStep.body(viewModel: lsbDecodingViewModel)
                    }
                    .navigationBarBackButtonHidden()
                    .navigationBarHidden(true)
                }
        }
        .overlay(alignment: .bottom) {
            VStack {
                ProgressView(
                    value: progress,
                    total: 1,
                    label: {
                        Text("진행상황")
                    }
                )
                .background(Color(.lightAccent))
                .labelsHidden()
                .opacity(navigationPath.isEmpty ? 0 : 1)
                .animation(.bouncy, value: navigationPath.isEmpty)

                HStack(spacing: 0) {
                    Button {
                        didTapBack()
                    } label: {
                        ZStack{
                            Circle()
                                .fill(Color.white)
                                .strokeBorder(Color.gray, lineWidth: 1)

                            Image(.icBack)
                                .resizable()
                                .frame(width: 20, height: 20)
                        }.frame(width: 44, height: 44)
                    }
                    .frame(width: navigationPath.isEmpty ? 0 : nil)
                    .padding(.trailing, navigationPath.isEmpty ? 0 : 16)
                    .opacity(navigationPath.isEmpty ? 0 : 1)
                    .animation(.spring, value: navigationPath.isEmpty)

                    Button {
                        didTapNext()
                    } label : {
                        HStack(spacing: 4){
                            if isNextButtonLoading {
                                ProgressView()
                                    .tint(Color.white)
                                    .frame(width: 20, height: 20)
                            } else {
                                Text("계속진행")
                                    .foregroundStyle(Color.white)
                                Image(.icNext)
                                    .resizable()
                                    .renderingMode(.template)
                                    .tint(Color.white)
                                    .frame(width: 20, height: 20)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background{
                            Capsule()
                                .fill(Color.black)
                        }
                    }
                }.padding()
            }
            .background(Color.white)
            .onChangeSize{

                footerHeight = $0.height
                print(footerHeight)
            }.environment(\.footerHeight, footerHeight)
        }
    }

    private func didTapBack() {
        cancellableBag.cancel()

        switch selectedWorkCategory{
        case .lsbDecoding:
            if let _ = lsbDecodingViewModel.navigationSteps.last {
                lsbDecodingViewModel.navigationSteps.removeLast()
                navigationPath.removeLast(navigationPath.count - lsbDecodingViewModel.navigationSteps.count)
            }
        case .lsbEncoding:
            if let _ = lsbEncodingViewModel.navigationSteps.last {
                lsbEncodingViewModel.navigationSteps.removeLast()
                navigationPath.removeLast(navigationPath.count - lsbEncodingViewModel.navigationSteps.count)
            }
        case .fileMergeDecoding:
            break
        case .fileMergeEncoding:
            break
        default:
            break
        }
    }

    private func didTapNext() {
        guard !isNextButtonLoading else { return }
        cancellableBag.cancel()
        Task{
            isNextButtonLoading = true
            do{
                switch selectedWorkCategory{
                case .lsbDecoding:
                    if let nextStep = try await lsbDecodingViewModel.nextStep() {
                        lsbDecodingViewModel.navigationSteps.append(nextStep)
                        navigationPath.append(nextStep)
                    }
                case .lsbEncoding:
                    if let nextStep = try await lsbEncodingViewModel.nextStep() {
                        lsbEncodingViewModel.navigationSteps.append(nextStep)
                        navigationPath.append(nextStep)
                    }
                case .fileMergeDecoding:
                    break
                case .fileMergeEncoding:
                    break
                default:
                    break
                }

                isNextButtonLoading = false
            }catch{
                print(error)

                isNextButtonLoading = false
            }
        }.add(to: cancellableBag)
    }
}

extension EnvironmentValues {
    @Entry var footerHeight: CGFloat = 0
}


#Preview {
    ContentView()
}

//struct ContentView: View {
//    @State private var isPresenting: Bool = false
//    @State private var pickedItem: PhotosPickerItem?
//    @State private var pickedImage: UIImage?
//
//    @State private var message: String = ""
//    @State private var password: String = ""
//
//    @State private var decodedMessage: String?
//    @State private var shouldShowAlert: Bool = false
//
//    private let cancellableBag = CancellableBag()
//
//    var body: some View {
//        GeometryReader { geometryProxy in
//            ZStack {
//                if let pickedImage {
//                    Image(uiImage: pickedImage)
//                        .resizable()
//                        .scaledToFill()
//                        .blur(radius: 8)
//                        .frame(width: geometryProxy.size.width)
//                        .ignoresSafeArea()
//                }else{
//                    Color.clear
//                        .ignoresSafeArea()
//                }
//
//                VStack {
//                    Text("Image Steganography")
//                        .font(.title)
//                        .fontWeight(.semibold)
//
//                    LabeledContent {
//                        TextField(text: $message) {
//                            Text("message to hide")
//                        }.textFieldStyle(.roundedBorder)
//                    } label: {
//                        Text("Message: ")
//                            .font(.subheadline)
//                            .fontWeight(.semibold)
//                    }
//                    LabeledContent {
//                        TextField(text: $password) {
//                            Text("password for encryption")
//                        }.textFieldStyle(.roundedBorder)
//                    } label: {
//                        Text("Password: ")
//                            .font(.subheadline)
//                            .fontWeight(.semibold)
//                    }
//
//                    Button {
//                        isPresenting = true
//                    } label: {
//                        Text("Select Original Image")
//                    }.buttonStyle(.borderedProminent)
//                }
//                .padding()
//            }
//            .overlay(alignment: .bottom) {
//                Button {
//                    Task { @MainActor in
//                        guard let pickedImage else{ return }
//                        let encoder: STEncodable = STPixelEncoder.shared
//                        do {
//                            guard let encodedString = StringEncoder.shared.encode(message, options: .plain) else{ return }
//                            let outputImage = try await encoder.encode(
//                                data: encodedString,
//                                into: pickedImage
//                            ) { progress in
//                                print("====", progress)
//                            }
//
//                            UIImageWriteToSavedPhotosAlbum(UIImage(data: outputImage.pngData()!)!, nil, nil, nil)
//                        } catch {
//                            print(error)
//                        }
//                    }
//                } label: {
//                    Text("Encode")
//                        .frame(maxWidth: .infinity, minHeight: 32)
//                }
//                .padding(.init(top: 16, leading: 32, bottom: 16, trailing: 32))
//                .buttonStyle(.borderedProminent)
//            }
//            .onChange(of: pickedItem, { oldValue, newValue in
//                guard oldValue != newValue else { return }
//                guard let pickedItem = newValue else { return }
//                cancellableBag.cancel()
//                Task {
//                    pickedImage = nil
//                    do {
//                        guard let data = try await pickedItem.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) else { return }
//                        pickedImage = uiImage
//                        let decodedMessage = try await STPixelDecoder.shared.decode(image: uiImage, with: .plain)
//                        if let decodedMessage {
//                            self.decodedMessage = decodedMessage
//                            self.shouldShowAlert = true
//                        }
//                    } catch {
//                        print(error)
//                    }
//                }.add(to: cancellableBag)
//            })
//            .photosPicker(isPresented: $isPresenting, selection: $pickedItem)
//            .alert(isPresented: $shouldShowAlert) {
//                Alert(title: Text("디코딩된 메시지"), message: Text(decodedMessage ?? ""))
//            }
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}
