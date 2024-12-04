//
//  View+onChangeSize.swift
//  Steganography
//
//  Created by 김수아 on 12/3/24.
//

import SwiftUI

private struct SizePreferenceKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {

    func onChangeSize(_ onChangeSize: @escaping ((CGSize) -> Void)) -> some View {
        self.background{
            GeometryReader{ geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        }.onPreferenceChange(SizePreferenceKey.self) { size in
            onChangeSize(size)
        }
    }
}
