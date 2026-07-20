//
//  CategoryLabel.swift
//  Mogapa
//
//  Created by Minjae Son on 7/20/26.
//

import SwiftUI

struct CategoryLabel: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            withAnimation {
                action()
            }
        } label: {
            Text(title)
                .typography(.bodyMedium)
                .foregroundStyle(
                    isSelected ? .textwhite : .textmuted )
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    isSelected ? .labelprimary : .labelwhite
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? Color.clear : .strokedefault, lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CategoryLabel(title: "최신순", isSelected: false, action: {})
}
