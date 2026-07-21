//
//  ModalHeader.swift
//  Mogapa
//
//  Created by sun on 7/20/26.
//

import SwiftUI

struct ModalHeader: View {
    let title: String
    let onClose: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        HStack {
            BasicButton(
                systemImage: "xmark",
                shape: .circle,
                foregroundStyle: .textprimary,
                font: .system(size: 24, weight: .medium)
            ) {
                onClose()
            }

            Spacer()

            Text(title)
                .typography(.subTitleMedium)
                .foregroundStyle(.textprimary)

            Spacer()

            BasicButton(
                systemImage: "checkmark",
                shape: .circle,
                foregroundStyle: .white,
                tint: .blue,
                font: .system(size: 22, weight: .semibold)
            ) {
                onConfirm()
            }
        }
        .padding(.horizontal, 20)
    }
}
