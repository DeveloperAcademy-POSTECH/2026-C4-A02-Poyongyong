//
//  BackButton.swift
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
        font: Font = .system(size: 22),
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.shape = shape
        self.foregroundStyle = AnyShapeStyle(foregroundStyle)
        self.font = font
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
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
            .background(.ultraThinMaterial)
            .clipShape(
                shape == .circle
                ? AnyShape(Circle())
                : AnyShape(Capsule())
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    BasicButton(
        systemImage: "gearshape.fill",
        shape: .circle,
        foregroundStyle: .white,
        font: .system(size: 24)
    ) {
        print("Settings tapped")
    }
}
