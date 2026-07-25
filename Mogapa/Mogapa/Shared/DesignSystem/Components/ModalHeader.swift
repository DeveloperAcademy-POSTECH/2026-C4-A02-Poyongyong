//
//  ModalHeader.swift
//  Mogapa
//
//  Created by sun on 7/20/26.
//

import SwiftUI

struct ModalHeader: View {
    let title: String
    let isConfirmEnabled: Bool
    let onClose: () -> Void
    let onConfirm: () -> Void

    init(
        title: String,
        isConfirmEnabled: Bool = true,
        onClose: @escaping () -> Void,
        onConfirm: @escaping () -> Void
    ) {
        self.title = title
        self.isConfirmEnabled = isConfirmEnabled
        self.onClose = onClose
        self.onConfirm = onConfirm
    }

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
                foregroundStyle:
                    isConfirmEnabled
                    ? .iconinverse
                    : .textmuted,
                tint:
                    isConfirmEnabled
                    ? .accentsBlue
                    : .clear,
                font: .system(size: 22, weight: .semibold),
                isProminent: isConfirmEnabled
            ) {
                onConfirm()
            }
            .disabled(!isConfirmEnabled)
        }
        .padding(.horizontal, 20)
    }
}
