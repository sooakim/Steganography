//
//  ExportingFile.swift
//  Steganography
//
//  Created by 김수아 on 12/5/24.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI

struct ExportingFile: FileDocument {
    static var readableContentTypes: [UTType] = [.item]

    let data: Data

    init(url: URL) throws {
        data = try Data(contentsOf: url)
    }

    init(_ data: Data){
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
