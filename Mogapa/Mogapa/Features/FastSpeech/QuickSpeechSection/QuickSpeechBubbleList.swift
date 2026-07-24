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
    let allowsMove: Bool
    let allowsFullSwipeDelete: Bool

    @Binding var selectedIDs: Set<ID>

    let spacing: CGFloat
    let showsIndicators: Bool

    let onTap: (ID) -> Void
    let onDelete: (ID) -> Void

    let onMove: (
        _ source: IndexSet,
        _ destination: Int
    ) -> Void

    @State private var lineLimits: [ID: Int] = [:]

    // MARK: Initializer

    init(
        items: [QuickSpeechBubbleListItem<ID>],
        isEditing: Bool = false,
        allowsMove: Bool = true,
        allowsFullSwipeDelete: Bool = false,
        selectedIDs: Binding<Set<ID>>,
        spacing: CGFloat = 10,
        showsIndicators: Bool = false,
        onTap: @escaping (ID) -> Void = { _ in },
        onDelete: @escaping (ID) -> Void = { _ in },
        onMove: @escaping (
            _ source: IndexSet,
            _ destination: Int
        ) -> Void = { _, _ in }
    ) {
        self.items = items
        self.isEditing = isEditing
        self.allowsMove = allowsMove
        self.allowsFullSwipeDelete = allowsFullSwipeDelete
        self._selectedIDs = selectedIDs
        self.spacing = spacing
        self.showsIndicators = showsIndicators
        self.onTap = onTap
        self.onDelete = onDelete
        self.onMove = onMove
    }

    // MARK: Body

    var body: some View {
        List {
            ForEach(items) { item in
                rowView(item)
                    .listRowInsets(
                        EdgeInsets(
                            top: spacing / 2,
                            leading: isEditing
                            ? 2
                            : 0,
                            bottom: spacing / 2,
                            trailing: 0
                        )
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(
                        edge: .trailing,
                        allowsFullSwipe: allowsFullSwipeDelete
                    ) {
                        if !isEditing {
                            Button(role: .destructive) {
                                delete(item.id)
                            } label: {
                                Image(.quickSpeechTrash)
                            }
                            .tint(.accentsRed)
                        }
                    }
            }
            .onMove { source, destination in
                guard isEditing, allowsMove else {
                    return
                }

                onMove(
                    source,
                    destination
                )
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .environment(
            \.editMode,
            .constant(
                isEditing
                ? EditMode.active
                : EditMode.inactive
            )
        )
        .environment(
            \.defaultMinListRowHeight,
            0
        )
        .scrollIndicators(
            showsIndicators
            ? .visible
            : .hidden
        )
        .onChange(of: isEditing) { _, newValue in
            guard !newValue else {
                return
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
        HStack(spacing: 12) {
            if isEditing {
                checkbox(
                    isSelected:
                        selectedIDs.contains(item.id)
                )
            }

            QuickSpeechBubble(
                text: item.text,
                isEditing: isEditing,
                preservedLineLimit: lineLimits[item.id],
                onLineLimitMeasured: {
                    lineLimits[item.id] = $0
                },
                action: nil
            )
            .padding(
                .trailing,
                isEditing && allowsMove
                ? 12
                : 0
            )
        }
        .contentShape(Rectangle())
        .moveDisabled(
            !isEditing ||
            !allowsMove
        )
        .onTapGesture {
            if isEditing {
                toggleSelection(for: item.id)
            } else {
                onTap(item.id)
            }
        }
    }

    func checkbox(
        isSelected: Bool
    ) -> some View {
        ZStack {
            Circle()
                .fill(
                    isSelected
                    ? .accentsBlue
                    : .backgroundbgCanvas
                )
                .overlay {
                    Circle()
                        .stroke(
                            isSelected
                            ? .accentsBlue
                            : .strokedefault,
                            lineWidth: 1
                        )
                }

            if isSelected {
                Image(systemName: "checkmark")
                    .font(
                        .system(
                            size: 10,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(.iconinverse)
            }
        }
        .frame(
            width: 18,
            height: 18
        )
        .contentShape(Circle())
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

    }
}

// MARK: - Preview

private struct QuickSpeechBubbleListPreview: View {
    @State private var isEditing = false
    @State private var allowsFullSwipeDelete = false
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

            Toggle(
                "전체 스와이프 삭제",
                isOn: $allowsFullSwipeDelete
            )

            QuickSpeechBubbleList(
                items: items,
                isEditing: isEditing,
                allowsFullSwipeDelete: allowsFullSwipeDelete,
                selectedIDs: $selectedIDs,
                onTap: { _ in },
                onDelete: { id in
                    withAnimation(.snappy) {
                        items.removeAll {
                            $0.id == id
                        }
                    }
                },
                onMove: { source, destination in
                    moveItem(
                        from: source,
                        to: destination
                    )
                }
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    private func moveItem(
        from source: IndexSet,
        to destination: Int
    ) {
        withAnimation(.interactiveSpring) {
            items.move(
                fromOffsets: source,
                toOffset: destination
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
