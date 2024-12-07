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

//enum FileMergeEncodingStep{
//    case test
//}
//
//struct FileMergeTestScreen: View {
//    @State var originalImage: UIImage?
//    @State private var originalItem: PhotosPickerItem?
//    @State private var isPresentingOriginal: Bool = false
//
//    @State var mergingImage: UIImage?
//    @State private var mergingItem: PhotosPickerItem?
//    @State private var isPresentingMerging: Bool = false
//
//    var body: some View {
//        VStack(spacing: 0) {
//            Text("""
//            사용할 이미지를 선택해주세요.
//            """)
//            .multilineTextAlignment(.leading)
//            .font(.title2)
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding()
//
//            VStack {
//                imagePicker(image: $originalImage, pickerItem: $originalItem, isPresenting: $isPresentingOriginal)
//
//                imagePicker(image: $mergingImage, pickerItem: $mergingItem, isPresenting: $isPresentingMerging)
//
//                Button{
//                    Task {
//                        guard let originalItem, let mergingItem else { return }
//                        guard let originalData = try await originalItem.loadTransferable(type: Data.self) else { return }
//                        guard let mergingData = try await mergingItem.loadTransferable(type: Data.self) else { return }
//                        let mergedData = originalData + mergingData
//
//                        guard let mergedImage = UIImage(data: mergedData) else { return }
//                        UIImageWriteToSavedPhotosAlbum(mergedImage, nil, nil, nil)
//                    }
//                } label : {
//                    Text("암호화")
//                }
//
//                Button{
//                    Task {
//
//                    }
//                } label : {
//                    Text("복호화")
//                }
//            }.frame(maxHeight: .infinity)
//        }
//    }
//
//    @ViewBuilder
//    func imagePicker(image: Binding<UIImage?>, pickerItem: Binding<PhotosPickerItem?>, isPresenting: Binding<Bool>) -> some View {
//        HStack(spacing: 16) {
//            if let image = image.wrappedValue {
//                Image.init(uiImage: image)
//                    .resizable()
//                    .frame(width: 44, height: 44)
//            } else {
//                Rectangle()
//                    .fill(Color.gray)
//                    .frame(width: 44, height: 44)
//            }
//
//            Text("이미지를 선택해주세요")
//
//            Spacer()
//        }
//        .padding()
//        .background{
//            RoundedRectangle(cornerRadius: 4)
//                .stroke(image.wrappedValue != nil ? Color(.accent) : Color.gray, lineWidth: 1)
//                .fill(image.wrappedValue != nil ? Color(.lightAccent) : Color.white)
//                .shadow(radius: 1, x: 1, y: 1)
//        }
//        .onTapGesture {
//            isPresenting.wrappedValue = true
//        }
//        .padding()
//        .photosPicker(isPresented: isPresenting, selection: pickerItem)
//        .photosPickerStyle(.presentation)
//        .onChange(of: pickerItem.wrappedValue) { pickedItem in
//            Task {
//                do{
//                    guard
//                        let pickedItem,
//                        let pickedImageData = try await pickedItem.loadTransferable(type: Data.self),
//                        let pickedImage = UIImage(data: pickedImageData)
//                    else{
//                        print("empty")
//                        image.wrappedValue = nil
//                        return
//                    }
//
//                    print("selectedImage")
//                    image.wrappedValue = pickedImage
//                }catch{
//                    image.wrappedValue = nil
//                    print(error)
//                }
//            }
//        }
//    }
//}

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
            lsbEncodingViewModel.progress()
        case .lsbDecoding:
            lsbDecodingViewModel.progress()
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
                    switch try await lsbDecodingViewModel.nextStep() {
                    case let .next(nextStep):
                        lsbDecodingViewModel.navigationSteps.append(nextStep)
                        navigationPath.append(nextStep)
                    case .clear:
                        navigationPath.removeLast(navigationPath.count)
                        lsbDecodingViewModel.clear()
                    case .pop:
                        lsbDecodingViewModel.navigationSteps.removeLast()
                        navigationPath.removeLast()
                    case nil:
                        break
                    }
                case .lsbEncoding:
                    switch try await lsbEncodingViewModel.nextStep() {
                    case let .next(nextStep):
                        lsbEncodingViewModel.navigationSteps.append(nextStep)
                        navigationPath.append(nextStep)
                    case .clear:
                        navigationPath.removeLast(navigationPath.count)
                        lsbEncodingViewModel.clear()
                    case .pop:
                        lsbEncodingViewModel.navigationSteps.removeLast()
                        navigationPath.removeLast()
                    case nil:
                        break
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
