//
//  SpeechModalContent.swift
//  Mogapa
//
//  Created by JENNA on 7/21/26.
//

import SwiftUI

struct SpeechModalContent: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var text: String
    // 기존 방식으로 되돌릴 때 사용:
    // @State private var showCategoryPicker = false
    @State private var selected: String
    
    let title: String
    let categories: [String]
    
    // selected 되는 값으로 바뀌게
    init(title: String, categories: [String], existingText: String = "") {
        self.title = title
        self.categories = categories
        _selected = State(initialValue: categories.first ?? "")
        _text = State(initialValue: existingText)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header

            content
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .background(Color(.backgroundbgDisabled))
        .contentShape(Rectangle())
        .onTapGesture {
            hideKeyboard()
        }
        .presentationDetents([.height(625)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(38)
        // 기존 방식으로 되돌릴 때 사용:
        // .sheet(isPresented: $showCategoryPicker) {
        //     CategoryPicker(selected: $selected, categories: categories)
        // }
    }
    
    private var header: some View {
        ModalHeader(
            title: title,
            onClose: {
                dismiss()
            },
            onConfirm: {
                print("저장")
                dismiss()
            }
        )
        .padding(.top, 22)
        .padding(.horizontal, 6)
    }
    
    private var content: some View {
        VStack(spacing: 16) {
            categorySelector
            
            RoundedTextField(text: $text)
                .frame(maxWidth: .infinity)
        }
        .padding(.top, 24)
        .padding(.horizontal, 16)
    }

    private var categorySelector: some View {
        // 기존 방식은 row tap 시 CategoryPicker sheet를 한 번 더 띄웠음.
        // PR 논의 후 기존 방식으로 되돌릴 경우 Menu 대신 아래 action을 가진 Button으로 복구.
        //
        // Button {
        //     showCategoryPicker = true
        // } label: {
        //     categorySelectorLabel
        // }
        // .buttonStyle(.plain)
        Menu {
            ForEach(categories, id: \.self) { category in
                Button {
                    selected = category
                } label: {
                    Label(
                        category,
                        systemImage: category == selected ? "checkmark" : ""
                    )
                }
            }
        } label: {
            categorySelectorLabel
        }
        .buttonStyle(.plain)
    }

    private var categorySelectorLabel: some View {
        HStack {
            Text("카테고리")
                .foregroundStyle(.textprimary)

            Spacer()

            Text(selected)
                .foregroundStyle(.texttertiary)

            Image(systemName: "chevron.down")
                .typography(.bodyMedium)
                .foregroundStyle(.textmuted)
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, minHeight: 52)
        .background {
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.backgroundbgCanvas)
        }
    }
}

#Preview {
    Color.gray
        .sheet(isPresented: .constant(true)) {
            SpeechModalContent(title: "제나", categories: ["임시카고", "제나", "주니", "이안", "빅토리아", "퍼플", "스우"])
        }
}
