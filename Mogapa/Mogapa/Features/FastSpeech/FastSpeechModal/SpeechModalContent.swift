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
    
    var body: some View {
        VStack(spacing: 0) {
            header

            //content
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
            SpeechModalContent(title: "제나")
        }
}
