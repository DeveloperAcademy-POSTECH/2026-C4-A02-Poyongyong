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
    let onAddCategory: (String) -> Void

    @Binding var selectedIndex: Int

    @State private var isAddingCategory = false
    @State private var newCategoryName = ""
    @FocusState private var isNewCategoryFocused: Bool

    init(
        categories: [FastSpeechCategory],
        selectedIndex: Binding<Int>,
        defaultTitle: String = "최근 문구",
        showsAddButton: Bool = false,
        onAddCategory: @escaping (String) -> Void = { _ in }
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

                if isAddingCategory {
                    newCategoryField
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
                        action: startAddingCategory
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var newCategoryField: some View {
        TextField("카테고리", text: $newCategoryName)
            .typography(.bodyMedium)
            .foregroundStyle(.textprimary)
            .submitLabel(.done)
            .focused($isNewCategoryFocused)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .frame(minWidth: 76)
            .fixedSize(horizontal: true, vertical: false)
            .background(.labelwhite)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(.strokefocus, lineWidth: 1)
            }
            .onSubmit {
                commitNewCategory()
            }
            .onChange(of: isNewCategoryFocused) { _, isFocused in
                guard !isFocused else { return }
                commitNewCategory()
            }
            .onAppear {
                isNewCategoryFocused = true
            }
    }

    private func startAddingCategory() {
        guard !isAddingCategory else {
            isNewCategoryFocused = true
            return
        }

        newCategoryName = ""
        withAnimation(.snappy) {
            isAddingCategory = true
        }
    }

    private func commitNewCategory() {
        guard isAddingCategory else { return }

        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        newCategoryName = ""

        withAnimation(.snappy) {
            isAddingCategory = false
        }

        guard !trimmedName.isEmpty else { return }
        onAddCategory(trimmedName)
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
        defaultTitle: "최근 문구",
        showsAddButton: true
    )
    .environment(\.locale, Locale(identifier: "ko"))
}
