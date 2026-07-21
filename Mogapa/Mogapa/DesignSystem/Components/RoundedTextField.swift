//
//  RoundedTextField.swift
//  Mogapa
//
//  Created by sun on 7/20/26.
//

import SwiftUI

struct RoundedTextField: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var placeholder: String = "입력해주세요"

    var body: some View {
        HStack(spacing: 12) {
            TextField(placeholder, text: $text)
                .focused($isFocused)
                .foregroundStyle(Color.textprimary)
                .tint(.blue)
                .submitLabel(.done)
                .onSubmit {
                    isFocused = false
                }

            if !text.isEmpty {
                Button {
                    text.removeAll()
                    isFocused = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .transition(.opacity.combined(with: .scale))
                .accessibilityLabel("입력 내용 지우기")
            }
        }
        .padding(.horizontal, 24)
        .frame(height: 52)
        .background {
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.backgroundbgCanvas)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 40)
                .stroke(
                    isFocused
                        ? Color.backgroundbgDefault
                        : Color.clear,
                    lineWidth: 2
                )
                .allowsHitTesting(false)
        }
        .contentShape(RoundedRectangle(cornerRadius: 40))
        .onTapGesture {
            isFocused = true
        }
        .animation(.easeInOut(duration: 0.15), value: isFocused)
        .animation(.easeInOut(duration: 0.15), value: text.isEmpty)
    }
}
