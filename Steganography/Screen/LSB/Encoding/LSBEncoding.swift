//
//  LSBEncodingRootView.swift
//  Steganography
//
//  Created by 김수아 on 12/4/24.
//

import SwiftUI

enum LSBEncodingNavigationStep: Int, CaseIterable {
    case hiddenDataType
    case messageInput
    case fileInput
    case hideIntoImage
    case export

    @ViewBuilder
    func body(@ObservedObject viewModel: LSBEncodingViewModel) ->  some View {
        switch self {
        case .hiddenDataType: LSBEncodingHiddenDataTypeScreen(selectedAttachmentType: $viewModel.selectedAttachmentType)
        case .messageInput: LSBEncodingMessageInputScreen(message: $viewModel.message, password: $viewModel.password)
        case .fileInput: LSBEncodingFileInputScreen(importingFile: $viewModel.importingFile, password: $viewModel.password)
        case .hideIntoImage: LSBEncodingHideIntoImageScreen(selectedImage: $viewModel.selectedImage)
        case .export: LSBEncodingExportScreen(selectedImage: $viewModel.exportImage)
        }
    }
}

final class LSBEncodingViewModel: ObservableObject {
    @Published var navigationSteps: [LSBEncodingNavigationStep] = []
    @Published var selectedAttachmentType: LSBAttachmentType?
    @Published var importingFile: URL?
    @Published var message: String = ""
    @Published var password: String = ""
    @Published var selectedImage: UIImage?
    @Published var exportImage: UIImage?

    func nextStep() async throws -> LSBEncodingNavigationStep? {
        switch navigationSteps.last {
        case .hiddenDataType:
            switch selectedAttachmentType {
            case .text: return .messageInput
            case .file: return .fileInput
            case nil: return nil
            }
        case .messageInput: return .hideIntoImage
        case .fileInput: return .hideIntoImage
        case .hideIntoImage:
            guard let selectedAttachmentType else { return nil }
            switch selectedAttachmentType {
            case .text:
                guard let selectedImage else { return nil }
                let options: DataEncodingOptions = if !password.isEmpty {
                    .encryptWithAES(password: password)
                } else {
                    .plain
                }
                guard let data = try StringDataEncoder.shared.encode(message, options: options) else { return nil }

                let header = options.asHeader() + selectedAttachmentType.asHeader()
                let image = try await STPixelEncoder.shared.encode(data: data, with: header, into: selectedImage)
                guard let pngData = image.pngData() else{ return nil }

                exportImage = UIImage(data: pngData)
                return .export
            case .file:
                guard let importingFile, let selectedImage else { return nil }
                let options: DataEncodingOptions = if !password.isEmpty {
                    .encryptWithAES(password: password)
                } else {
                    .plain
                }
                guard let data = try FileDataEncoder.shared.encode(importingFile, options: options) else { return nil }

                let header = options.asHeader() + selectedAttachmentType.asHeader()
                let image = try await STPixelEncoder.shared.encode(data: data, with: header, into: selectedImage)
                guard let pngData = image.pngData() else{ return nil }

                exportImage = UIImage(data: pngData)
                return .export
            }
        case .export:
            navigationSteps.removeAll()
            return .hiddenDataType
        case nil: return .hiddenDataType
        }
    }
}

private extension LSBAttachmentType {
    func asHeader() -> STHeader {
        switch self {
        case .text: .text
        case .file: .file
        }
    }
}
