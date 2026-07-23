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
    var isPinned: Bool

    init(
        id: ID,
        text: String,
        isPinned: Bool = false
    ) {
        self.id = id
        self.text = text
        self.isPinned = isPinned
    }
}

// MARK: - List Section

struct QuickSpeechBubbleListSection<ID: Hashable> {
    let title: String?
    let items: [QuickSpeechBubbleListItem<ID>]

    init(
        title: String? = nil,
        items: [QuickSpeechBubbleListItem<ID>]
    ) {
        self.title = title
        self.items = items
    }
}

// MARK: - Quick Speech Bubble List

struct QuickSpeechBubbleList<ID: Hashable>: View {

    // MARK: Properties

    let sections: [QuickSpeechBubbleListSection<ID>]
    let isEditing: Bool

    @Binding var selectedIDs: Set<ID>

    let spacing: CGFloat
    let sectionSpacing: CGFloat
    let showsIndicators: Bool

    let onTap: (ID) -> Void
    let onPin: (ID) -> Void
    let onUnpin: (ID) -> Void
    let onDelete: (ID) -> Void

    /// sourceID를 destinationID 위치로 이동합니다.
    let onMove: (
        _ sourceID: ID,
        _ destinationID: ID
    ) -> Void

    @State private var openedRowID: ID?
    @State private var draggedItemID: ID?
    @State private var lineLimits: [ID: Int] = [:]

    // MARK: Initializer - Sections

    init(
        sections: [QuickSpeechBubbleListSection<ID>],
        isEditing: Bool = false,
        selectedIDs: Binding<Set<ID>>,
        spacing: CGFloat = 10,
        sectionSpacing: CGFloat = 28,
        showsIndicators: Bool = false,
        onTap: @escaping (ID) -> Void = { _ in },
        onPin: @escaping (ID) -> Void = { _ in },
        onUnpin: @escaping (ID) -> Void = { _ in },
        onDelete: @escaping (ID) -> Void = { _ in },
        onMove: @escaping (
            _ sourceID: ID,
            _ destinationID: ID
        ) -> Void = { _, _ in }
    ) {
        self.sections = sections
        self.isEditing = isEditing
        self._selectedIDs = selectedIDs
        self.spacing = spacing
        self.sectionSpacing = sectionSpacing
        self.showsIndicators = showsIndicators
        self.onTap = onTap
        self.onPin = onPin
        self.onUnpin = onUnpin
        self.onDelete = onDelete
        self.onMove = onMove
    }

    // MARK: Initializer - Single Section

    init(
        title: String? = nil,
        items: [QuickSpeechBubbleListItem<ID>],
        isEditing: Bool = false,
        selectedIDs: Binding<Set<ID>>,
        spacing: CGFloat = 10,
        showsIndicators: Bool = false,
        onTap: @escaping (ID) -> Void = { _ in },
        onPin: @escaping (ID) -> Void = { _ in },
        onUnpin: @escaping (ID) -> Void = { _ in },
        onDelete: @escaping (ID) -> Void = { _ in },
        onMove: @escaping (
            _ sourceID: ID,
            _ destinationID: ID
        ) -> Void = { _, _ in }
    ) {
        self.init(
            sections: [
                QuickSpeechBubbleListSection(
                    title: title,
                    items: items
                )
            ],
            isEditing: isEditing,
            selectedIDs: selectedIDs,
            spacing: spacing,
            showsIndicators: showsIndicators,
            onTap: onTap,
            onPin: onPin,
            onUnpin: onUnpin,
            onDelete: onDelete,
            onMove: onMove
        )
    }

    // MARK: Body

    var body: some View {
        ScrollView(
            .vertical,
            showsIndicators: showsIndicators
        ) {
            LazyVStack(
                alignment: .leading,
                spacing: sectionSpacing
            ) {
                ForEach(
                    Array(sections.enumerated()),
                    id: \.offset
                ) { _, section in
                    sectionView(section)
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
        sections.flatMap { section in
            section.items.map(\.id)
        }
    }

    func sectionView(
        _ section: QuickSpeechBubbleListSection<ID>
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: spacing
        ) {
            if let title = section.title {
                sectionTitle(title)
            }

            ForEach(section.items) { item in
                rowView(
                    item,
                    section: section
                )
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    func rowView(
        _ item: QuickSpeechBubbleListItem<ID>,
        section: QuickSpeechBubbleListSection<ID>
    ) -> some View {
        QuickSpeechBubbleRow(
            id: item.id,
            text: item.text,
            isPinned: item.isPinned,
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
            onPin: {
                onPin(item.id)
            },
            onUnpin: {
                onUnpin(item.id)
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

                let sectionIDs = Set(
                    section.items.map(\.id)
                )

                return sectionIDs.contains(sourceID) &&
                    sectionIDs.contains(destinationID)
            },
            onMove: { sourceID, destinationID in
                onMove(
                    sourceID,
                    destinationID
                )
            }
        )
    }

    func sectionTitle(
        _ title: String
    ) -> some View {
        Text(title)
            .typography(.subTitleBold)
            .foregroundStyle(.textprimary)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
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

    func moveDraggedItem(
        to destinationID: ID,
        in section: QuickSpeechBubbleListSection<ID>
    ) {
        guard isEditing else {
            return
        }

        guard let sourceID = draggedItemID else {
            return
        }

        guard sourceID != destinationID else {
            return
        }

        /*
         같은 섹션 안에서만 순서를 변경합니다.

         sections가 isPinned 기준으로 나뉘어 있으므로,
         고정됨 섹션과 최신순 섹션 사이의 이동은 허용하지 않습니다.
         */
        guard section.items.contains(
            where: { $0.id == sourceID }
        ) else {
            return
        }

        withAnimation(.interactiveSpring) {
            onMove(
                sourceID,
                destinationID
            )
        }
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
            """,
            isPinned: true
        ),
        QuickSpeechBubbleListItem(
            id: UUID(),
            text: "고정된 텍스트 입력",
            isPinned: true
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
                sections: sections,
                isEditing: isEditing,
                selectedIDs: $selectedIDs,
                onTap: { _ in },
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

    private var sections:
        [QuickSpeechBubbleListSection<UUID>] {
        [
            QuickSpeechBubbleListSection(
                title: "고정됨",
                items: items.filter(\.isPinned)
            ),
            QuickSpeechBubbleListSection(
                title: "최신순",
                items: items.filter {
                    !$0.isPinned
                }
            )
        ]
    }

    private func updatePinnedState(
        for id: UUID,
        isPinned: Bool
    ) {
        guard let index = items.firstIndex(
            where: { $0.id == id }
        ) else {
            return
        }

        withAnimation(.snappy) {
            items[index].isPinned = isPinned
        }
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

        /*
         고정된 항목과 일반 항목은 서로 다른 섹션이므로
         같은 섹션 안에서만 순서를 변경합니다.
         */
        guard items[sourceIndex].isPinned ==
                items[destinationIndex].isPinned else {
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
