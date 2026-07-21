//
//  FastSpeechView.swift
//  Mogapa
//
//  Created by Purple on 7/22/26.
//

import SwiftUI

struct FastSpeechView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedCategoryIndex = 0
    @State private var isEditing = false
    @State private var selectedIDs: Set<UUID> = []
    @State private var presentedModal: FastSpeechModal?
    @State private var categories: [FastSpeechCategory]
    @State private var phrases: [FastSpeechViewPhrase]

    init() {
        let dummyData = FastSpeechViewDummyData.make()
        _categories = State(initialValue: dummyData.categories)
        _phrases = State(initialValue: dummyData.phrases)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 18) {
                header

                FastSpeechCategorySelector(
                    categories: categories,
                    selectedIndex: $selectedCategoryIndex,
                    defaultTitle: "최근 말하기",
                    showsAddButton: true,
                    onAddCategory: {
                        presentedModal = .add
                    }
                )
                .padding(.horizontal, 20)

                QuickSpeechBubbleList(
                    sections: bubbleSections,
                    isEditing: isEditing,
                    selectedIDs: $selectedIDs,
                    onTap: { id in
                        guard let phrase = phrases.first(where: { $0.id == id }) else { return }
                        presentedModal = .edit(phrase.text)
                    },
                    onPin: { updatePinnedState(for: $0, isPinned: true) },
                    onUnpin: { updatePinnedState(for: $0, isPinned: false) },
                    onDelete: { deletePhrase($0) }
                )
                .padding(.horizontal, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            if !isEditing {
                CreateButton {
                    presentedModal = .add
                }
                .padding(.trailing, 31)
                .padding(.bottom, 8)
            }
        }
        .background(.backgroundbgCanvas)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $presentedModal) { modal in
            SpeechModalContent(
                title: modal.title,
                categories: categoryNames,
                existingText: modal.existingText
            )
        }
    }
}

private extension FastSpeechView {
    var header: some View {
        MogapaNavigationHeader(
            title: "빠른 말하기",
            rightTitle: isEditing ? nil : "편집",
            rightSystemImage: isEditing ? "trash.fill" : nil,
            isRightDisabled: isEditing && selectedIDs.isEmpty,
            rightTint: isEditing ? .accentsRed : .clear,
            rightForegroundStyle: isEditing ? .iconinverse : .textsecondary,
            leftTitle: isEditing ? "취소" : nil,
            leftIcon: isEditing ? nil : "chevron.left",
            leftAccessibilityLabel: isEditing ? "편집 종료" : "뒤로 가기",
            onLeftTap: handleLeftTap,
            onRightTap: handleRightTap
        )
    }

    var categoryNames: [String] {
        ["최근 말하기"] + categories.map(\.name)
    }

    var filteredPhrases: [FastSpeechViewPhrase] {
        guard selectedCategoryIndex > 0 else { return phrases }

        let categoryIndex = selectedCategoryIndex - 1
        guard categories.indices.contains(categoryIndex) else { return [] }

        let selectedCategoryID = categories[categoryIndex].id
        return phrases.filter { $0.categoryID == selectedCategoryID }
    }

    var bubbleSections: [QuickSpeechBubbleListSection<UUID>] {
        let pinnedItems = filteredPhrases
            .filter(\.isPinned)
            .map(quickSpeechBubbleItem)
        let recentItems = filteredPhrases
            .filter { !$0.isPinned }
            .map(quickSpeechBubbleItem)

        guard !pinnedItems.isEmpty else {
            return [
                QuickSpeechBubbleListSection(items: recentItems)
            ]
        }

        return [
            QuickSpeechBubbleListSection(
                title: "고정됨",
                items: pinnedItems
            ),
            QuickSpeechBubbleListSection(
                title: "최신순",
                items: recentItems
            )
        ]
    }

    func quickSpeechBubbleItem(
        _ phrase: FastSpeechViewPhrase
    ) -> QuickSpeechBubbleListItem<UUID> {
        QuickSpeechBubbleListItem(
            id: phrase.id,
            text: phrase.text,
            isPinned: phrase.isPinned
        )
    }

    func handleLeftTap() {
        if isEditing {
            withAnimation(.snappy) {
                isEditing = false
                selectedIDs.removeAll()
            }
        } else {
            dismiss()
        }
    }

    func handleRightTap() {
        if isEditing {
            deleteSelectedPhrases()
        } else {
            withAnimation(.snappy) {
                isEditing = true
            }
        }
    }

    func updatePinnedState(for id: UUID, isPinned: Bool) {
        guard let index = phrases.firstIndex(where: { $0.id == id }) else { return }

        withAnimation(.snappy) {
            phrases[index].isPinned = isPinned
        }
    }

    func deletePhrase(_ id: UUID) {
        withAnimation(.snappy) {
            selectedIDs.remove(id)
            phrases.removeAll { $0.id == id }
        }
    }

    func deleteSelectedPhrases() {
        guard !selectedIDs.isEmpty else { return }

        withAnimation(.snappy) {
            phrases.removeAll { selectedIDs.contains($0.id) }
            selectedIDs.removeAll()
        }
    }
}

private enum FastSpeechModal: Identifiable {
    case add
    case edit(String)

    var id: String {
        switch self {
        case .add:
            "add"

        case let .edit(text):
            "edit-\(text)"
        }
    }

    var title: String {
        switch self {
        case .add:
            "빠른 말하기 추가"

        case .edit:
            "빠른 말하기 수정"
        }
    }

    var existingText: String {
        switch self {
        case .add:
            ""

        case let .edit(text):
            text
        }
    }
}

#Preview {
    FastSpeechView()
        .environment(\.locale, Locale(identifier: "ko"))
}
