//
//  BasicButton.swift
//  Mogapa
//
//  Created by Minjae Son on 7/20/26.
//

import SwiftUI

struct BasicButton: View {
    let title: String?
    let systemImage: String?
    let shape: BasicButtonShape
    let foregroundStyle: AnyShapeStyle
    let tint: Color
    let font: Font
    let action: () -> Void

    enum BasicButtonShape {
        case circle
        case capsule
    }

    init(
        title: String? = nil,
        systemImage: String? = nil,
        shape: BasicButtonShape = .capsule,
        foregroundStyle: some ShapeStyle = .primary,
        tint: Color = .clear,
        font: Font = .system(size: 22),
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.shape = shape
        self.foregroundStyle = AnyShapeStyle(foregroundStyle)
        self.tint = tint
        self.font = font
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                }

                if let title {
                    Text(title)
                }
            }
            .font(font)
            .foregroundStyle(foregroundStyle)
            .padding(.horizontal, shape == .circle ? 0 : 16)
            .frame(
                width: shape == .circle ? 44 : nil,
                height: 44
            )
            .background {
                buttonShape
                    .fill(.ultraThinMaterial)

                buttonShape
                    .fill(tint)
            }
            .clipShape(buttonShape)
            .overlay {
                buttonShape
                    .fill(.white.opacity(0.1))
            }
            .overlay {
                buttonShape
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.8),
                                .gray.opacity(0.4),
                                .white.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        }
        .buttonStyle(.plain)
    }

    private var buttonShape: AnyShape {
        switch shape {
        case .circle:
            AnyShape(Circle())

        case .capsule:
            AnyShape(Capsule())
        }
    }
}
