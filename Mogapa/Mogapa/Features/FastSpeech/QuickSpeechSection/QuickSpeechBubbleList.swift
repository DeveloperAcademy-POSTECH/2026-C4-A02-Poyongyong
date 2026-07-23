//
//  QuickSpeechBubbleList.swift
//  Mogapa
//
//  Created by Purple on 7/22/26.
//

import SwiftUI

// MARK: - List Item

struct QuickSpeechBubbleListItem<ID: Hashable>: Identifiable {
    let id: ID
    let text: String

    init(
        id: ID,
        text: String
    ) {
        self.id = id
        self.text = text
    }
}

// MARK: - Quick Speech Bubble List

struct QuickSpeechBubbleList<ID: Hashable>: View {

    // MARK: Properties

    let items: [QuickSpeechBubbleListItem<ID>]
    let isEditing: Bool

    @Binding var selectedIDs: Set<ID>

    let spacing: CGFloat
    let showsIndicators: Bool

    let onTap: (ID) -> Void
    let onDelete: (ID) -> Void

    /// sourceID를 destinationID 위치로 이동합니다.
    let onMove: (
        _ sourceID: ID,
        _ destinationID: ID
    ) -> Void

    @State private var openedRowID: ID?
    @State private var draggedItemID: ID?
    @State private var lineLimits: [ID: Int] = [:]

    // MARK: Initializer

    init(
        items: [QuickSpeechBubbleListItem<ID>],
        isEditing: Bool = false,
        selectedIDs: Binding<Set<ID>>,
        spacing: CGFloat = 10,
        showsIndicators: Bool = false,
        onTap: @escaping (ID) -> Void = { _ in },
        onDelete: @escaping (ID) -> Void = { _ in },
        onMove: @escaping (
            _ sourceID: ID,
            _ destinationID: ID
        ) -> Void = { _, _ in }
    ) {
        self.items = items
        self.isEditing = isEditing
        self._selectedIDs = selectedIDs
        self.spacing = spacing
        self.showsIndicators = showsIndicators
        self.onTap = onTap
        self.onDelete = onDelete
        self.onMove = onMove
    }

    // MARK: Body

    var body: some View {
        ScrollView(
            .vertical,
            showsIndicators: showsIndicators
        ) {
            LazyVStack(
                alignment: .leading,
                spacing: spacing
            ) {
                ForEach(items) { item in
                    rowView(item)
                }
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
        .onChange(of: isEditing) { _, newValue in
            if newValue {
                openedRowID = nil
            } else {
                draggedItemID = nil
            }
        }
        .onChange(of: itemIDs) { _, newValue in
            trimCachedState(
                validIDs: Set(newValue)
            )
        }
    }
}

// MARK: - Subviews

private extension QuickSpeechBubbleList {
    var itemIDs: [ID] {
        items.map(\.id)
    }

    func rowView(
        _ item: QuickSpeechBubbleListItem<ID>
    ) -> some View {
        QuickSpeechBubbleRow(
            id: item.id,
            text: item.text,
            isSelected: selectedIDs.contains(item.id),
            isEditing: isEditing,
            preservedLineLimit: lineLimits[item.id],
            onLineLimitMeasured: {
                lineLimits[item.id] = $0
            },
            openedRowID: $openedRowID,
            onTap: {
                onTap(item.id)
            },
            onSelectionToggle: {
                toggleSelection(
                    for: item.id
                )
            },
            onDelete: {
                delete(item.id)
            }
        )
        .opacity(
            draggedItemID == item.id
            ? 0.5
            : 1
        )
        .animation(
            .easeInOut(duration: 0.15),
            value: draggedItemID
        )
        .dragDrop(
            isEditing: isEditing,
            itemID: item.id,
            draggedItemID: $draggedItemID,
            canMove: { sourceID, destinationID in
                guard sourceID != destinationID else {
                    return false
                }

                return itemIDs.contains(sourceID) &&
                    itemIDs.contains(destinationID)
            },
            onMove: { sourceID, destinationID in
                onMove(
                    sourceID,
                    destinationID
                )
            }
        )
    }
}

// MARK: - Drag and Drop

private extension QuickSpeechBubbleList {
    func startDragging(
        itemID: ID
    ) {
        guard isEditing else {
            return
        }

        openedRowID = nil
        draggedItemID = itemID
    }

    func endDragging() {
        draggedItemID = nil
    }
}

// MARK: - Actions

private extension QuickSpeechBubbleList {
    func toggleSelection(
        for id: ID
    ) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

    func delete(
        _ id: ID
    ) {
        selectedIDs.remove(id)
        lineLimits[id] = nil

        if openedRowID == id {
            openedRowID = nil
        }

        if draggedItemID == id {
            draggedItemID = nil
        }

        onDelete(id)
    }

    func trimCachedState(
        validIDs: Set<ID>
    ) {
        selectedIDs = selectedIDs.filter {
            validIDs.contains($0)
        }

        lineLimits = lineLimits.filter {
            validIDs.contains($0.key)
        }

        if let openedRowID,
           !validIDs.contains(openedRowID) {
            self.openedRowID = nil
        }

        if let draggedItemID,
           !validIDs.contains(draggedItemID) {
            self.draggedItemID = nil
        }
    }
}

// MARK: - Preview

private struct QuickSpeechBubbleListPreview: View {
    @State private var isEditing = false
    @State private var selectedIDs: Set<UUID> = []

    @State private var items = [
        QuickSpeechBubbleListItem(
            id: UUID(),
            text: """
            얼마나 길게 써지나 함 봐볼까요. 근데 이거 길게 쓰면 밑으로 내려가네요. 딱 맞춰서 이어지는지!!!
            """
        ),
        QuickSpeechBubbleListItem(
            id: UUID(),
            text: "텍스트 입력"
        ),
        QuickSpeechBubbleListItem(
            id: UUID(),
            text: "텍스트 입력 1"
        ),
        QuickSpeechBubbleListItem(
            id: UUID(),
            text: "텍스트 입력 2"
        ),
        QuickSpeechBubbleListItem(
            id: UUID(),
            text: "텍스트 입력 3"
        ),
        QuickSpeechBubbleListItem(
            id: UUID(),
            text: "텍스트 입력 4"
        ),
        QuickSpeechBubbleListItem(
            id: UUID(),
            text: "텍스트 입력 5"
        ),
        QuickSpeechBubbleListItem(
            id: UUID(),
            text: "텍스트 입력 6"
        ),
        QuickSpeechBubbleListItem(
            id: UUID(),
            text: "텍스트 입력 7"
        )
    ]

    var body: some View {
        VStack(spacing: 18) {
            Button(
                isEditing ? "완료" : "편집"
            ) {
                withAnimation(.snappy) {
                    isEditing.toggle()
                }
            }

            QuickSpeechBubbleList(
                items: items,
                isEditing: isEditing,
                selectedIDs: $selectedIDs,
                onTap: { _ in },
                onDelete: { id in
                    withAnimation(.snappy) {
                        items.removeAll {
                            $0.id == id
                        }
                    }
                },
                onMove: { sourceID, destinationID in
                    moveItem(
                        sourceID: sourceID,
                        destinationID: destinationID
                    )
                }
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    private func moveItem(
        sourceID: UUID,
        destinationID: UUID
    ) {
        guard let sourceIndex = items.firstIndex(
            where: { $0.id == sourceID }
        ) else {
            return
        }

        guard let destinationIndex = items.firstIndex(
            where: { $0.id == destinationID }
        ) else {
            return
        }

        guard sourceIndex != destinationIndex else {
            return
        }

        withAnimation(.interactiveSpring) {
            let movedItem = items.remove(
                at: sourceIndex
            )

            /*
             sourceIndex의 아이템을 먼저 제거하면
             뒤쪽 destinationIndex가 한 칸 당겨집니다.
             */
            let insertionIndex: Int

            if sourceIndex < destinationIndex {
                insertionIndex =
                    destinationIndex - 1
            } else {
                insertionIndex =
                    destinationIndex
            }

            items.insert(
                movedItem,
                at: insertionIndex
            )
        }
    }
}

#Preview("QuickSpeechBubbleList") {
    QuickSpeechBubbleListPreview()
        .environment(
            \.locale,
            Locale(identifier: "ko")
        )
}
