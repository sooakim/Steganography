//
//  QuestionList.swift
//  Steganography
//
//  Created by 김수아 on 12/3/24.
//

import SwiftUI

struct Question<Identifier: Hashable>: Identifiable {
    let id: Identifier
    let iconResource: ImageResource
    let title: String
    var isSelected: Bool = false
}

struct QuestionList<Identifier: Hashable>: View {
    @State var questions: [Question<Identifier>]
    @Binding var selectedWorkCategory: Identifier?
    let didTapQuestion: (() -> Void)?

    @Environment(\.footerHeight) private var footerHeight: CGFloat

    var body: some View {
        List {
            Group{
                ForEach(questions) { question in
                    QuestionListItem(question: question, didTap: {
                        didTapQuestion(question)
                    })
                }

                Spacer()
                    .frame(height: footerHeight)
            }.ignoreListStyle()
        }
        .listStyle(.plain)
    }

    private func didTapQuestion(_ question: Question<Identifier>) {
        questions = questions.map{ newWork in
            var newWork = newWork
            newWork.isSelected = question.id == newWork.id
            return newWork
        }

        selectedWorkCategory = question.id
    }
}

private extension QuestionList{
    struct QuestionListItem: View {
        let question: Question<Identifier>
        let didTap: (() -> Void)

        var body: some View {
            HStack(spacing: 16) {
                Image.init(question.iconResource)
                    .resizable()
                    .frame(width: 44, height: 44)

                Text(question.title)

                Spacer()
            }
            .padding()
            .background{
                RoundedRectangle(cornerRadius: 4)
                    .stroke(question.isSelected ? Color(.accent) : Color.gray, lineWidth: 1)
                    .fill(question.isSelected ? Color(.lightAccent) : Color.white)
                    .shadow(radius: 1, x: 1, y: 1)
            }
            .onTapGesture(perform: didTap)
            .padding()
        }
    }
}


private extension View {
    func ignoreListStyle() -> some View {
        self.listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}

#Preview {
    QuestionList<String>(
        questions: [],
        selectedWorkCategory: .constant(nil),
        didTapQuestion: nil
    )
}
