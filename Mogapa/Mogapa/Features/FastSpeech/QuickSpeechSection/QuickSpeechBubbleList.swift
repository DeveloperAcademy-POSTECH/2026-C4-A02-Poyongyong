//
//  QuickSpeechBubbleList.swift
//  Mogapa
//
//  Created by Purple on 7/22/26.
//

import SwiftUI

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

struct QuickSpeechBubbleList<ID: Hashable>: View {
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

    @State private var openedRowID: ID?
    @State private var lineLimits: [ID: Int] = [:]

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
        onDelete: @escaping (ID) -> Void = { _ in }
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
    }

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
        onDelete: @escaping (ID) -> Void = { _ in }
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
            onDelete: onDelete
        )
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: showsIndicators) {
            LazyVStack(alignment: .leading, spacing: sectionSpacing) {
                ForEach(sections.indices, id: \.self) { index in
                    sectionView(sections[index])
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onChange(of: isEditing) { _, newValue in
            guard newValue else { return }
            openedRowID = nil
        }
        .onChange(of: itemIDs) { _, newValue in
            trimCachedState(validIDs: Set(newValue))
        }
    }

    private var itemIDs: [ID] {
        sections.flatMap { section in
            section.items.map(\.id)
        }
    }

    private func sectionView(
        _ section: QuickSpeechBubbleListSection<ID>
    ) -> some View {
        VStack(alignment: .leading, spacing: spacing) {
            if let title = section.title {
                sectionTitle(title)
            }

            ForEach(section.items) { item in
                QuickSpeechBubbleRow(
                    id: item.id,
                    text: item.text,
                    isPinned: item.isPinned,
                    isSelected: selectedIDs.contains(item.id),
                    isEditing: isEditing,
                    preservedLineLimit: lineLimits[item.id],
                    onLineLimitMeasured: { lineLimits[item.id] = $0 },
                    openedRowID: $openedRowID,
                    onTap: { onTap(item.id) },
                    onSelectionToggle: { toggleSelection(for: item.id) },
                    onPin: { onPin(item.id) },
                    onUnpin: { onUnpin(item.id) },
                    onDelete: { delete(item.id) }
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .typography(.subTitleBold)
            .foregroundStyle(.textprimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func toggleSelection(for id: ID) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

    private func delete(_ id: ID) {
        selectedIDs.remove(id)
        lineLimits[id] = nil

        if openedRowID == id {
            openedRowID = nil
        }

        onDelete(id)
    }

    private func trimCachedState(validIDs: Set<ID>) {
        selectedIDs = selectedIDs.filter { validIDs.contains($0) }
        lineLimits = lineLimits.filter { validIDs.contains($0.key) }

        if let openedRowID, !validIDs.contains(openedRowID) {
            self.openedRowID = nil
        }
    }
}

private struct QuickSpeechBubbleListPreview: View {
    @State private var isEditing = false
    @State private var selectedIDs: Set<UUID> = []
    @State private var items = [
        QuickSpeechBubbleListItem(
            id: UUID(),
            text: "얼마나 길게 써지나 함 봐볼까요. 근데 이거 길게 쓰면 밑으로 내려가네요. 딱 맞춰서 이어지는지!!!",
            isPinned: true
        ),
        QuickSpeechBubbleListItem(id: UUID(), text: "고정된 텍스트 입력", isPinned: true),
        QuickSpeechBubbleListItem(id: UUID(), text: "텍스트 입력 1"),
        QuickSpeechBubbleListItem(id: UUID(), text: "텍스트 입력 2"),
        QuickSpeechBubbleListItem(id: UUID(), text: "텍스트 입력 3"),
        QuickSpeechBubbleListItem(id: UUID(), text: "텍스트 입력 4"),
        QuickSpeechBubbleListItem(id: UUID(), text: "텍스트 입력 5"),
        QuickSpeechBubbleListItem(id: UUID(), text: "텍스트 입력 6"),
        QuickSpeechBubbleListItem(id: UUID(), text: "텍스트 입력 7")
    ]

    var body: some View {
        VStack(spacing: 18) {
            Button(isEditing ? "완료" : "편집") {
                withAnimation(.snappy) {
                    isEditing.toggle()
                }
            }

            QuickSpeechBubbleList(
                sections: sections,
                isEditing: isEditing,
                selectedIDs: $selectedIDs,
                onTap: { _ in },
                onPin: { updatePinnedState(for: $0, isPinned: true) },
                onUnpin: { updatePinnedState(for: $0, isPinned: false) },
                onDelete: { id in
                    withAnimation(.snappy) {
                        items.removeAll { $0.id == id }
                    }
                }
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    private var sections: [QuickSpeechBubbleListSection<UUID>] {
        [
            QuickSpeechBubbleListSection(
                title: "고정됨",
                items: items.filter(\.isPinned)
            ),
            QuickSpeechBubbleListSection(
                title: "최신순",
                items: items.filter { !$0.isPinned }
            )
        ]
    }

    private func updatePinnedState(for id: UUID, isPinned: Bool) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }

        withAnimation(.snappy) {
            items[index].isPinned = isPinned
        }
    }
}

#Preview("QuickSpeechBubbleList") {
    QuickSpeechBubbleListPreview()
        .environment(\.locale, Locale(identifier: "ko"))
}
