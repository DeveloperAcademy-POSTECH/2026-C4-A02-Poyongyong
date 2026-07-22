//
//  FastSpeechCategorySelector.swift
//  Mogapa
//
//  Created by Minjae Son on 7/21/26.
//

import SwiftUI

struct FastSpeechCategorySelector: View {
    private static let leadingScrollID = "fast-speech-category-leading"

    private let categoryMinWidth: CGFloat = 84
    private let categoryHeight: CGFloat = 36
    private let horizontalPadding: CGFloat = 28
    private let commitDelay: Duration = .milliseconds(120)
    private let shortCommitAnimationDuration: Duration = .milliseconds(140)

    let categories: [FastSpeechCategory]
    let defaultTitle: String
    let showsAddButton: Bool
    let onAddCategory: (String) -> Void
    let onAddingStateChange: (Bool) -> Void

    @Binding var selectedIndex: Int

    @State private var isAddingCategory = false
    @State private var selectedIndexBeforeAdding = 0
    @State private var newCategoryName = ""
    @State private var newCategoryTextWidth: CGFloat = 0
    @State private var committedCategoryFieldWidth: CGFloat?
    @State private var isCommittingCategory = false
    @FocusState private var isNewCategoryFocused: Bool

    init(
        categories: [FastSpeechCategory],
        selectedIndex: Binding<Int>,
        defaultTitle: String = "최근 문구",
        showsAddButton: Bool = false,
        onAddCategory: @escaping (String) -> Void = { _ in },
        onAddingStateChange: @escaping (Bool) -> Void = { _ in }
    ) {
        self.categories = categories
        self._selectedIndex = selectedIndex
        self.defaultTitle = defaultTitle
        self.showsAddButton = showsAddButton
        self.onAddCategory = onAddCategory
        self.onAddingStateChange = onAddingStateChange
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    CategoryLabel(
                        title: defaultTitle,
                        isSelected: selectedIndex == 0
                    ) {
                        selectedIndex = 0
                    }
                    .id(Self.leadingScrollID)

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
                            isSelected: false
                        ) {
                            startAddingCategory()
                            withAnimation(.snappy) {
                                proxy.scrollTo(
                                    Self.leadingScrollID,
                                    anchor: .leading
                                )
                            }
                        }
                    }
                }
                .padding(.vertical, 2)
            }
            .frame(minHeight: categoryHeight + 4)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var newCategoryField: some View {
        ZStack(alignment: .leading) {
            TextField("카테고리", text: $newCategoryName)
                .typography(.bodyMedium)
                .foregroundStyle(.textprimary)
                .submitLabel(.done)
                .focused($isNewCategoryFocused)
                .opacity(isCommittingCategory ? 0 : 1)
                .onSubmit {
                    commitNewCategory()
                }
                .onChange(of: isNewCategoryFocused) { _, isFocused in
                    guard !isFocused else { return }
                    commitNewCategory()
                }

            if isCommittingCategory {
                Text(newCategoryName)
                    .typography(.bodyMedium)
                    .foregroundStyle(.textprimary)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .background {
            Text(newCategoryName.isEmpty ? "카테고리" : newCategoryName)
                .typography(.bodyMedium)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .hidden()
                .readWidth { width in
                    newCategoryTextWidth = width
                }
        }
            .frame(
                width: newCategoryContentWidth,
                alignment: .leading
            )
            .padding(.horizontal, horizontalPadding / 2)
            .padding(.vertical, 8)
            .frame(width: newCategoryFieldWidth)
            .frame(minHeight: categoryHeight)
            .fixedSize(horizontal: true, vertical: false)
            .background(.labelwhite)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(.strokefocus, lineWidth: 1)
            }
            .onAppear {
                isNewCategoryFocused = true
            }
    }

    private var newCategoryFieldWidth: CGFloat {
        if let committedCategoryFieldWidth {
            return committedCategoryFieldWidth
        }

        return max(
            categoryMinWidth,
            newCategoryTextWidth + horizontalPadding
        )
    }

    private var newCategoryContentWidth: CGFloat {
        max(
            0,
            newCategoryFieldWidth - horizontalPadding
        )
    }

    private var targetCategoryFieldWidth: CGFloat {
        newCategoryTextWidth + horizontalPadding
    }

    private func startAddingCategory() {
        guard !isAddingCategory else {
            isNewCategoryFocused = true
            return
        }

        newCategoryName = ""
        committedCategoryFieldWidth = nil
        isCommittingCategory = false
        selectedIndexBeforeAdding = selectedIndex
        withAnimation(.snappy) {
            selectedIndex = -1
            isAddingCategory = true
        }
        onAddingStateChange(true)
    }

    private func commitNewCategory() {
        guard isAddingCategory else { return }
        guard !isCommittingCategory else { return }

        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            withAnimation(.snappy) {
                isAddingCategory = false
                selectedIndex = selectedIndexBeforeAdding
            }
            isCommittingCategory = false
            onAddingStateChange(false)
            return
        }

        newCategoryName = trimmedName
        isCommittingCategory = true
        isNewCategoryFocused = false

        guard targetCategoryFieldWidth < categoryMinWidth else {
            Task { @MainActor in
                try? await Task.sleep(for: commitDelay)

                withAnimation(.snappy) {
                    isAddingCategory = false
                }

                onAddCategory(trimmedName)
                newCategoryName = ""
                isCommittingCategory = false
                onAddingStateChange(false)
            }
            return
        }

        committedCategoryFieldWidth = newCategoryFieldWidth

        withAnimation(.snappy(duration: 0.14)) {
            committedCategoryFieldWidth = targetCategoryFieldWidth
        }

        Task { @MainActor in
            try? await Task.sleep(
                for: shortCommitAnimationDuration
            )

            isAddingCategory = false
            onAddCategory(trimmedName)
            newCategoryName = ""
            committedCategoryFieldWidth = nil
            isCommittingCategory = false
            onAddingStateChange(false)
        }
    }
}

private struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private extension View {
    func readWidth(_ onChange: @escaping (CGFloat) -> Void) -> some View {
        background {
            GeometryReader { proxy in
                Color.clear
                    .preference(
                        key: WidthPreferenceKey.self,
                        value: proxy.size.width
                    )
            }
        }
        .onPreferenceChange(
            WidthPreferenceKey.self,
            perform: onChange
        )
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
