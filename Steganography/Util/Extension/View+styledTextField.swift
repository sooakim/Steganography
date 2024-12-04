//
//  View+styledTextField.swift
//  Steganography
//
//  Created by 김수아 on 12/4/24.
//

import SwiftUI

extension View {
    @ViewBuilder
    func styledTextField() -> some View {
        self.padding(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
            .background {
                Capsule()
                    .fill(Color(.lightAccent))
                    .strokeBorder(Color(.accent), lineWidth: 1)
            }
            .foregroundStyle(Color.black)
    }
}
