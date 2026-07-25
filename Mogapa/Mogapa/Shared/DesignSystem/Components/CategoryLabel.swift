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
    let minWidth: CGFloat?
    let action: () -> Void

    init(
        title: String,
        isSelected: Bool,
        minWidth: CGFloat? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.minWidth = minWidth
        self.action = action
    }

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
                .frame(minWidth: minWidth)
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
        .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview {
    CategoryLabel(title: "최신순", isSelected: false, action: {})
}
