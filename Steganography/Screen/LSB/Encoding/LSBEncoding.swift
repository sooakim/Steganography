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

    func progress() -> CGFloat {
        let maxCount = 4
        return switch navigationSteps.last {
        case .hiddenDataType: CGFloat(1) / CGFloat(maxCount)
        case .messageInput, .fileInput: CGFloat(2) / CGFloat(maxCount)
        case .hideIntoImage: CGFloat(3) / CGFloat(maxCount)
        case .export: CGFloat(4) / CGFloat(maxCount)
        case nil: 0
        }
    }

    func nextStep() async throws -> NavigationStep<LSBEncodingNavigationStep>? {
        switch navigationSteps.last {
        case .hiddenDataType:
            switch selectedAttachmentType {
            case .text: return .next(.messageInput)
            case .file: return .next(.fileInput)
            case nil: return nil
            }
        case .messageInput: return .next(.hideIntoImage)
        case .fileInput: return .next(.hideIntoImage)
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

                await MainActor.run {
                    exportImage = UIImage(data: pngData)
                }
                return .next(.export)
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

                await MainActor.run {
                    exportImage = UIImage(data: pngData)
                }
                return .next(.export)
            }
        case .export: return .clear
        case nil: return .next(.hiddenDataType)
        }
    }

    func clear(){
        navigationSteps = []
        selectedAttachmentType = nil
        importingFile = nil
        message = ""
        password = ""
        selectedImage = nil
        exportImage = nil
    }
}

private extension LSBAttachmentType {
    func asHeader() -> STLSBHeader {
        switch self {
        case .text: .text
        case .file: .file
        }
    }
}
