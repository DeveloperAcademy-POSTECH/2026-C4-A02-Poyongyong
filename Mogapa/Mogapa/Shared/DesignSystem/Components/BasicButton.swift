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
    let isProminent: Bool
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
        isProminent: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.shape = shape
        self.foregroundStyle = AnyShapeStyle(foregroundStyle)
        self.tint = tint
        self.font = font
        self.isProminent = isProminent
        self.action = action
    }
    
    var body: some View {
        if isProminent {
            buttonContent
                .applyButtonBorderShape(for: shape)
                .tint(tint)
                .buttonStyle(.glassProminent)
        } else {
            buttonContent
                .applyButtonBorderShape(for: shape)
                .tint(tint)
                .buttonStyle(.glass)
        }
    }

    private var buttonContent: some View {
        Button(action: action) {
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
            .padding(.horizontal, shape == .circle ? 0 : 4)
            .frame(
                width: shape == .circle ? 22 : nil,
                height: 32
            )
        }
    }
}

private extension View {
    @ViewBuilder
    func applyButtonBorderShape(
        for shape: BasicButton.BasicButtonShape
    ) -> some View {
        switch shape {
        case .circle:
            self/*.buttonBorderShape(.circle)*/
            
        case .capsule:
            self
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        BasicButton(
            systemImage: "gearshape.fill",
            shape: .circle,
            foregroundStyle: .white,
            font: .system(size: 24)
        ) {
            print("Settings tapped")
        }

        BasicButton(
            title: "Continue",
            systemImage: "arrow.right",
            shape: .capsule,
            foregroundStyle: .white,
            font: .system(size: 18)
        ) {
            print("Continue tapped")
        }
    }
    .padding()
}

