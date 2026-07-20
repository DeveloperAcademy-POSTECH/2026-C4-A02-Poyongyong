//
//  CreateButton.swift
//  Mogapa
//
//  Created by Purple on 7/20/26.
//

import SwiftUI

struct CreateButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .labelprimary.opacity(0.88),
                                .labelprimary
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.25), lineWidth: 1)
                    }
                    .glassEffect(.regular, in: Circle())

                Image("CreateButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
            .frame(width: 44, height: 44)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .shadow(color: .black.opacity(0.22), radius: 2, x: 0, y: 2)
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
