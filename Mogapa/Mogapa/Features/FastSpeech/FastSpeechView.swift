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

        _categories = State(
            initialValue: dummyData.categories
        )

        _phrases = State(
            initialValue: dummyData.phrases
        )
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
                    onAddCategory: {}
                )
                .padding(.horizontal, 20)

                QuickSpeechBubbleList(
                    sections: bubbleSections,
                    isEditing: isEditing,
                    selectedIDs: $selectedIDs,
                    onTap: { id in
                        guard let phrase = phrases.first(
                            where: { $0.id == id }
                        ) else {
                            return
                        }

                        presentedModal = .edit(
                            phrase.text
                        )
                    },
                    onPin: { id in
                        updatePinnedState(
                            for: id,
                            isPinned: true
                        )
                    },
                    onUnpin: { id in
                        updatePinnedState(
                            for: id,
                            isPinned: false
                        )
                    },
                    onDelete: { id in
                        deletePhrase(id)
                    },
                    onMove: { sourceID, destinationID in
                        movePhrase(
                            sourceID: sourceID,
                            destinationID: destinationID
                        )
                    }
                )
                .padding(.horizontal, 20)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )

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
        .toolbar(
            .hidden,
            for: .navigationBar
        )
        .sheet(
            item: $presentedModal
        ) { modal in
            SpeechModalContent(
                title: modal.title,
                categories: categoryNames,
                existingText: modal.existingText
            )
        }
        .onChange(
            of: selectedCategoryIndex
        ) { _, _ in
            selectedIDs.removeAll()
        }
    }
}

// MARK: - Computed Properties

private extension FastSpeechView {
    var header: some View {
        MogapaNavigationHeader(
            title: "빠른 말하기",
            rightTitle: isEditing
                ? nil
                : "편집",
            rightSystemImage: isEditing
                ? "trash.fill"
                : nil,
            isRightDisabled:
                isEditing &&
                selectedIDs.isEmpty,
            rightTint: isEditing
                ? .accentsRed
                : .clear,
            rightForegroundStyle: isEditing
                ? .iconinverse
                : .textsecondary,
            leftTitle: isEditing
                ? "취소"
                : nil,
            leftIcon: isEditing
                ? nil
                : "chevron.left",
            leftAccessibilityLabel: isEditing
                ? "편집 종료"
                : "뒤로 가기",
            onLeftTap: handleLeftTap,
            onRightTap: handleRightTap
        )
    }

    var categoryNames: [String] {
        categories.map(\.name)
    }

    var filteredPhrases: [FastSpeechViewPhrase] {
        guard selectedCategoryIndex > 0 else {
            return phrases
        }

        let categoryIndex =
            selectedCategoryIndex - 1

        guard categories.indices.contains(
            categoryIndex
        ) else {
            return []
        }

        let selectedCategoryID =
            categories[categoryIndex].id

        return phrases.filter {
            $0.categoryID == selectedCategoryID
        }
    }

    var bubbleSections:
        [QuickSpeechBubbleListSection<UUID>] {
        let pinnedItems = filteredPhrases
            .filter(\.isPinned)
            .map(quickSpeechBubbleItem)

        let recentItems = filteredPhrases
            .filter {
                !$0.isPinned
            }
            .map(quickSpeechBubbleItem)

        guard !pinnedItems.isEmpty else {
            return [
                QuickSpeechBubbleListSection(
                    items: recentItems
                )
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
}

// MARK: - Mapping

private extension FastSpeechView {
    func quickSpeechBubbleItem(
        _ phrase: FastSpeechViewPhrase
    ) -> QuickSpeechBubbleListItem<UUID> {
        QuickSpeechBubbleListItem(
            id: phrase.id,
            text: phrase.text,
            isPinned: phrase.isPinned
        )
    }
}

// MARK: - Navigation Actions

private extension FastSpeechView {
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
}

// MARK: - Phrase Actions

private extension FastSpeechView {
    func updatePinnedState(
        for id: UUID,
        isPinned: Bool
    ) {
        guard let index = phrases.firstIndex(
            where: { $0.id == id }
        ) else {
            return
        }

        withAnimation(.snappy) {
            phrases[index].isPinned = isPinned
        }
    }

    func deletePhrase(
        _ id: UUID
    ) {
        withAnimation(.snappy) {
            selectedIDs.remove(id)

            phrases.removeAll {
                $0.id == id
            }
        }
    }

    func deleteSelectedPhrases() {
        guard !selectedIDs.isEmpty else {
            return
        }

        withAnimation(.snappy) {
            phrases.removeAll {
                selectedIDs.contains($0.id)
            }

            selectedIDs.removeAll()
        }
    }
}

// MARK: - Reordering

private extension FastSpeechView {
    func movePhrase(
        sourceID: UUID,
        destinationID: UUID
    ) {
        guard sourceID != destinationID else {
            return
        }

        guard let sourceIndex = phrases.firstIndex(
            where: { $0.id == sourceID }
        ) else {
            return
        }

        guard let destinationIndex = phrases.firstIndex(
            where: { $0.id == destinationID }
        ) else {
            return
        }

        let sourcePhrase =
            phrases[sourceIndex]

        let destinationPhrase =
            phrases[destinationIndex]

        /*
         고정된 문구와 일반 문구는 서로 다른 섹션이므로
         섹션을 넘어가는 이동을 허용하지 않습니다.
         */
        guard sourcePhrase.isPinned ==
                destinationPhrase.isPinned else {
            return
        }

        /*
         카테고리가 선택된 상태에서는
         다른 카테고리 문구로 이동하지 않도록 막습니다.
         */
        guard sourcePhrase.categoryID ==
                destinationPhrase.categoryID else {
            return
        }

        withAnimation(
            .interactiveSpring(
                response: 0.25,
                dampingFraction: 0.85
            )
        ) {
            phrases.move(
                fromOffsets: IndexSet(
                    integer: sourceIndex
                ),
                toOffset: sourceIndex < destinationIndex
                    ? destinationIndex + 1
                    : destinationIndex
            )
        }
    }
}

// MARK: - Modal

private enum FastSpeechModal: Identifiable {
    case add
    case edit(String)

    var id: String {
        switch self {
        case .add:
            return "add"

        case let .edit(text):
            return "edit-\(text)"
        }
    }

    var title: String {
        switch self {
        case .add:
            return "빠른 말하기 추가"

        case .edit:
            return "빠른 말하기 수정"
        }
    }

    var existingText: String {
        switch self {
        case .add:
            return ""

        case let .edit(text):
            return text
        }
    }
}

// MARK: - Preview

#Preview {
    FastSpeechView()
        .environment(
            \.locale,
            Locale(identifier: "ko")
        )
}
