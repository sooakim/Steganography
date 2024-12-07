//
//  LSBDecodingRootView.swift
//  Steganography
//
//  Created by 김수아 on 12/4/24.
//

import Foundation
import SwiftUI

enum LSBDecodingNavigationStep: Int, CaseIterable {
    case `import`
    case passwordInput
    case message
    case file

    @ViewBuilder
    func body(@ObservedObject viewModel: LSBDecodingViewModel) ->  some View {
        switch self {
        case .import: LSBDecodingImportScreen(selectedImage: $viewModel.selectedImage)
        case .passwordInput: LSBDecodingPasswordInputScreen(password: $viewModel.password)
        case .message: LSBDecodingMessageScreen(message: $viewModel.message)
        case .file: LSBDecodingFileScreen(exportingFile: $viewModel.exportingFile)
        }
    }
}

final class LSBDecodingViewModel: ObservableObject {
    @Published var navigationSteps: [LSBDecodingNavigationStep] = []
    @Published var selectedImage: UIImage?
    @Published var password: String = ""
    @Published var message: String = ""
    @Published var exportingFile: ExportingFile?

    private var decodedHeader: STLSBHeader?

    func progress() -> CGFloat {
        var needsPassword = decodedHeader?.contains(.encryptWithAES256) ?? false
        let maxCount = needsPassword ? 3 : 2
        return switch navigationSteps.last {
        case .import: CGFloat(1) / CGFloat(maxCount)
        case .passwordInput: CGFloat(2) / CGFloat(maxCount)
        case .message, .file: CGFloat(needsPassword ? 3 : 2) / CGFloat(maxCount)
        case nil: 0
        }
    }

    func nextStep() async throws -> NavigationStep<LSBDecodingNavigationStep>? {
        switch navigationSteps.last {
        case .import:
            guard let selectedImage else { return nil }
            guard let decodedHeader = try await STPixelDecoder.shared.decodeHeader(image: selectedImage) else { return nil }
            await MainActor.run{
                self.decodedHeader = decodedHeader
            }

            if decodedHeader.contains(.encryptWithAES256) {
                return .next(.passwordInput)
            }

            if decodedHeader.contains(.text), let decodedMessage = try await decodeText(from: selectedImage, options: .plain) {
                await MainActor.run{
                    message = decodedMessage
                }
                return .next(.message)
            }

            if decodedHeader.contains(.file), let decodedFileURL = try await decodeFile(from: selectedImage, options: .plain) {
                try await MainActor.run{
                    exportingFile = try ExportingFile(url: decodedFileURL)
                }
                return .next(.file)
            }

            return nil
        case .passwordInput:
            guard let selectedImage, let decodedHeader else { return nil }
            guard !password.isEmpty else { return nil }

            if decodedHeader.contains(.text), let decodedMessage = try await decodeText(from: selectedImage, options: .encryptWithAES(password: password)) {
                await MainActor.run{
                    message = decodedMessage
                }
                return .next(.message)
            }

            if decodedHeader.contains(.file), let decodedFileURL = try await decodeFile(from: selectedImage, options: .encryptWithAES(password: password)) {
                try await MainActor.run{
                    exportingFile = try ExportingFile(url: decodedFileURL)
                }
                return .next(.file)
            }

            return nil
        case .message: return .clear
        case .file: return .clear
        case nil: return .next(.import)
        }
    }

    func clear() {
        navigationSteps = []
        selectedImage = nil
        password = ""
        message = ""
        exportingFile = nil
    }

    private func decodeText(from image: UIImage, options: DataEncodingOptions) async throws -> String? {
        guard let data = try await STPixelDecoder.shared.decode(image: image, progressHandler: { print("decoding...", $0) }) else { return nil }
        guard let string = try StringDataDecoder.shared.decode(data, options: options) else { return nil }
        return string
    }

    private func decodeFile(from image: UIImage, options: DataEncodingOptions) async throws -> URL? {
        guard let data = try await STPixelDecoder.shared.decode(image: image, progressHandler: { print("decoding...", $0) }) else { return nil }
        guard let fileURL = try FileDataDecoder.shared.decode(data, options: options) else { return nil }
        return fileURL
    }
}

struct LSBDecodingRootView: View {
    @ObservedObject var viewModel = LSBDecodingViewModel()

    var body: some View {
        LSBDecodingNavigationStep.import.body(viewModel: viewModel)
    }
}
