//
//  DragDropModifier.swift
//  Mogapa
//
//  Created by sun on 7/22/26.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - View Extension

extension View {
    func dragDrop<ID: Hashable>(
        isEditing: Bool,
        itemID: ID,
        draggedItemID: Binding<ID?>,
        canMove: @escaping (
            _ sourceID: ID,
            _ destinationID: ID
        ) -> Bool = { _, _ in true },
        onMove: @escaping (
            _ sourceID: ID,
            _ destinationID: ID
        ) -> Void
    ) -> some View {
        modifier(
            DragDropModifier(
                isEditing: isEditing,
                itemID: itemID,
                draggedItemID: draggedItemID,
                canMove: canMove,
                onMove: onMove
            )
        )
    }
}

// MARK: - Modifier

private struct DragDropModifier<ID: Hashable>: ViewModifier {
    let isEditing: Bool
    let itemID: ID

    @Binding var draggedItemID: ID?

    let canMove: (
        _ sourceID: ID,
        _ destinationID: ID
    ) -> Bool

    let onMove: (
        _ sourceID: ID,
        _ destinationID: ID
    ) -> Void

    func body(content: Content) -> some View {
        if isEditing {
            content
                .contentShape(Rectangle())
                .onDrag {
                    draggedItemID = itemID

                    return NSItemProvider(
                        object: String(
                            describing: itemID
                        ) as NSString
                    )
                } preview: {
                    content
                        .opacity(0.85)
                        .scaleEffect(1.02)
                }
                .onDrop(
                    of: [UTType.text],
                    delegate: ReorderDropDelegate(
                        destinationID: itemID,
                        draggedItemID: $draggedItemID,
                        canMove: canMove,
                        onMove: onMove
                    )
                )
        } else {
            content
        }
    }
}

// MARK: - Drop Delegate

private struct ReorderDropDelegate<ID: Hashable>:
    DropDelegate
{
    let destinationID: ID

    @Binding var draggedItemID: ID?

    let canMove: (
        _ sourceID: ID,
        _ destinationID: ID
    ) -> Bool

    let onMove: (
        _ sourceID: ID,
        _ destinationID: ID
    ) -> Void

    func dropEntered(
        info: DropInfo
    ) {
        guard let sourceID = draggedItemID else {
            return
        }

        guard sourceID != destinationID else {
            return
        }

        guard canMove(
            sourceID,
            destinationID
        ) else {
            return
        }

        withAnimation(
            .interactiveSpring(
                response: 0.25,
                dampingFraction: 0.85
            )
        ) {
            onMove(
                sourceID,
                destinationID
            )
        }
    }

    func dropUpdated(
        info: DropInfo
    ) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(
        info: DropInfo
    ) -> Bool {
        DispatchQueue.main.async {
            draggedItemID = nil
        }

        return true
    }

    func dropExited(
        info: DropInfo
    ) {}

    func validateDrop(
        info: DropInfo
    ) -> Bool {
        draggedItemID != nil
    }
}
