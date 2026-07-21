//
//  FastSpeechCategorySelector.swift
//  Mogapa
//
//  Created by Minjae Son on 7/21/26.
//

import SwiftUI

struct FastSpeechCategorySelector: View {
    let categories: [FastSpeechCategory]
    let defaultTitle: String
    let showsAddButton: Bool
    let onAddCategory: () -> Void

    @Binding var selectedIndex: Int

    init(
        categories: [FastSpeechCategory],
        selectedIndex: Binding<Int>,
        defaultTitle: String = "최근순",
        showsAddButton: Bool = false,
        onAddCategory: @escaping () -> Void = {}
    ) {
        self.categories = categories
        self._selectedIndex = selectedIndex
        self.defaultTitle = defaultTitle
        self.showsAddButton = showsAddButton
        self.onAddCategory = onAddCategory
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryLabel(
                    title: defaultTitle,
                    isSelected: selectedIndex == 0
                ) {
                    selectedIndex = 0
                }

                ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
                    CategoryLabel(
                        title: category.name,
                        isSelected: selectedIndex == index + 1
                    ) {
                        selectedIndex = index + 1
                    }
                }

                if showsAddButton {
                    CategoryLabel(
                        title: "+",
                        isSelected: false,
                        action: onAddCategory
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    @Previewable @State var selectedIndex = 0

    FastSpeechCategorySelector(
        categories: [
            FastSpeechCategory(name: "직장", sortOrder: 0),
            FastSpeechCategory(name: "병원", sortOrder: 1),
            FastSpeechCategory(name: "일상", sortOrder: 2)
        ],
        selectedIndex: $selectedIndex,
        defaultTitle: "최근 말하기",
        showsAddButton: true
    )
    .environment(\.locale, Locale(identifier: "ko"))
}
