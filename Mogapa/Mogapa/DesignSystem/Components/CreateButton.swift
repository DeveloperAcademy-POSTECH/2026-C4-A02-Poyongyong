//
//  CreateButton.swift
//  Mogapa
//
//  Created by Purple on 7/20/26.
//

import SwiftUI

struct CreateButton: View {
    var systemImage: String? = nil
    var showsTint: Bool = true   // 추가: false면 그라디언트 없이 표시
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        showsTint
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [
                                        .labelprimary.opacity(0.88),
                                        .labelprimary
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            : AnyShapeStyle(.clear)
                    )
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.25), lineWidth: 1)
                    }
                    .glassEffect(.regular, in: Circle())

                iconView
                    .frame(width: 20, height: 20)
            }
            .frame(width: 48, height: 48)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .shadow(color: .black.opacity(0.22), radius: 2, x: 0, y: 2)
    }

    @ViewBuilder
    private var iconView: some View {
        if let systemImage {
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white)
        } else {
            Image("CreateButton")
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview("CreateButton") {
    CreateButton(action: {})
        .environment(\.locale, Locale(identifier: "ko"))
}

#Preview("Floating") {
    ZStack(alignment: .bottomTrailing) {
        Color.white
            .ignoresSafeArea()

        CreateButton(action: {})
            .padding(.trailing, 31)
            .padding(.bottom, 8)
    }
    .environment(\.locale, Locale(identifier: "ko"))
}
