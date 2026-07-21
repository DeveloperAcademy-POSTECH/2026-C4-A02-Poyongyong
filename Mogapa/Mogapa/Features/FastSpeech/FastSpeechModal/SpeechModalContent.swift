//
//  SpeechModalContent.swift
//  Mogapa
//
//  Created by JENNA on 7/21/26.
//

import SwiftUI

struct SpeechModalContent: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    
    @State private var selected: String
    let categories: [String]
    
    // selected 되는 값으로 바뀌게
    init(title: String, categories: [String]) {
        self.title = title
        self.categories = categories
        _selected = State(initialValue: categories.first ?? "")
    }
    
    @State private var text = ""
    
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
        .presentationDetents([.height(725)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(38)
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
            HStack {
                Text("카테고리")
                    .foregroundStyle(.textprimary)
                Spacer()
                Text("아카데미")
                    .foregroundStyle(.texttertiary)
                Image(systemName: "chevron.right")
                    .typography(.bodyMedium)
                    .foregroundStyle(.textmuted)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background {
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color.backgroundbgCanvas)
            }
            
            RoundedTextField(text: $text)
                .frame(maxWidth: .infinity)
        }
        .padding(.top, 24)
        .padding(.horizontal, 16)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

#Preview {
    Color.gray
        .sheet(isPresented: .constant(true)) {
            SpeechModalContent(title: "제나", categories: ["임시카고"])
        }
}
