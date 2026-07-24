//
//  DragGestureEditViewModel.swift
//  Mogapa
//
//  Created by sun on 7/23/26.
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class DragGestureEditViewModel {

    // MARK: - State

    var gestures: [RegisteredDragGesture]
    var isEditing = false
    var selectedIDs: Set<UUID> = []
    var presentedModal: DragGestureEditModal?
    var draggingID: UUID?


    // MARK: - Private

    private var modelContext: ModelContext?
    private let usesInjectedData: Bool


    // MARK: - Initializer

    init(
        gestures: [RegisteredDragGesture] = []
    ) {
        self.gestures = gestures.sorted {
            if $0.sortOrder == $1.sortOrder {
                return $0.createdAt < $1.createdAt
            }

            return $0.sortOrder < $1.sortOrder
        }

        usesInjectedData = !gestures.isEmpty
    }


    // MARK: - Load

    func load(
        modelContext: ModelContext
    ) {
        self.modelContext = modelContext

        guard !usesInjectedData else {
            normalizeSortOrder(
                shouldSave: false
            )
            return
        }

        fetchGestures()
    }

    func fetchGestures() {
        guard let modelContext else {
            return
        }

        let descriptor =
            FetchDescriptor<RegisteredDragGesture>(
                sortBy: [
                    SortDescriptor(
                        \RegisteredDragGesture.sortOrder,
                        order: .forward
                    ),
                    SortDescriptor(
                        \RegisteredDragGesture.createdAt,
                        order: .forward
                    )
                ]
            )

        do {
            gestures = try modelContext.fetch(
                descriptor
            )

            normalizeSortOrder(
                shouldSave: false
            )
        } catch {
            print(
                "드래그 제스처 조회 실패: \(error)"
            )
        }
    }
}


// MARK: - Edit Mode

extension DragGestureEditViewModel {

    func beginEditing() {
        draggingID = nil
        selectedIDs.removeAll()
        isEditing = true
    }

    func cancelEditing() {
        selectedIDs.removeAll()
        isEditing = false
    }
}


// MARK: - Selection

extension DragGestureEditViewModel {

    func handleItemTap(
        _ gesture: RegisteredDragGesture
    ) {
        if isEditing {
            toggleSelection(
                gesture.id
            )
            return
        }

        presentEditModal(
            for: gesture
        )
    }

    func toggleSelection(
        _ id: UUID
    ) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

    func isSelected(
        _ id: UUID
    ) -> Bool {
        selectedIDs.contains(id)
    }
}


// MARK: - Modal

extension DragGestureEditViewModel {

    func presentAddModal() {
        presentedModal = .add
    }

    func presentEditModal(
        for gesture: RegisteredDragGesture
    ) {
        presentedModal = .edit(
            id: gesture.id, name: gesture.phrase,
            phrase: gesture.phrase
        )
    }

    func dismissModal() {
        presentedModal = nil
    }
}


// MARK: - Create

extension DragGestureEditViewModel {

    func addGesture(
        phrase: String,
        points: [DragPoint] = []
    ) {
        let newGesture =
            RegisteredDragGesture(
                phrase: phrase,
                points: points,
                sortOrder: gestures.count
            )

        gestures.append(
            newGesture
        )

        if !usesInjectedData {
            modelContext?.insert(
                newGesture
            )
        }

        normalizeSortOrder()
        presentedModal = nil
    }
}


// MARK: - Update

extension DragGestureEditViewModel {

    func updateGesture(
        id: UUID,
        name: String,
        phrase: String,
        points: [DragPoint]? = nil
    ) {
        guard let gesture =
                gestures.first(
                    where: {
                        $0.id == id
                    }
                )
        else {
            return
        }

        gesture.phrase = phrase
        gesture.updatedAt = .now

        if let points {
            gesture.points = points
        }

        saveModelContext()
        presentedModal = nil
    }
}


// MARK: - Delete

extension DragGestureEditViewModel {

    func deleteGesture(
        _ gesture: RegisteredDragGesture
    ) {
        selectedIDs.remove(
            gesture.id
        )

        gestures.removeAll {
            $0.id == gesture.id
        }

        if !usesInjectedData {
            modelContext?.delete(
                gesture
            )
        }

        normalizeSortOrder()
    }

    func deleteGesture(
        id: UUID
    ) {
        guard let gesture =
                gestures.first(
                    where: {
                        $0.id == id
                    }
                )
        else {
            return
        }

        deleteGesture(
            gesture
        )
    }

    func deleteSelectedGestures() {
        guard !selectedIDs.isEmpty else {
            return
        }

        let deletingGestures =
            gestures.filter {
                selectedIDs.contains(
                    $0.id
                )
            }

        gestures.removeAll {
            selectedIDs.contains(
                $0.id
            )
        }

        if !usesInjectedData {
            for gesture in deletingGestures {
                modelContext?.delete(
                    gesture
                )
            }
        }

        selectedIDs.removeAll()
        isEditing = false

        normalizeSortOrder()
    }
    
    func moveGesture(
        sourceID: UUID,
        destinationID: UUID
    ) {
        guard
            let sourceIndex = gestures.firstIndex(
                where: { $0.id == sourceID }
            ),
            let destinationIndex = gestures.firstIndex(
                where: { $0.id == destinationID }
            ),
            sourceIndex != destinationIndex
        else {
            return
        }

        let gesture = gestures.remove(
            at: sourceIndex
        )

        let adjustedDestinationIndex =
            sourceIndex < destinationIndex
            ? destinationIndex - 1
            : destinationIndex

        gestures.insert(
            gesture,
            at: adjustedDestinationIndex
        )
    }
}


// MARK: - Reordering

extension DragGestureEditViewModel {

    func beginDragging(
        _ id: UUID
    ) {
        guard !isEditing else {
            return
        }

        guard gestures.contains(
            where: {
                $0.id == id
            }
        ) else {
            return
        }

        draggingID = id
    }

    func moveDraggingGesture(
        before destinationID: UUID
    ) {
        guard
            !isEditing,
            let draggingID,
            draggingID != destinationID,
            let sourceIndex =
                gestures.firstIndex(
                    where: {
                        $0.id == draggingID
                    }
                ),
            let destinationIndex =
                gestures.firstIndex(
                    where: {
                        $0.id == destinationID
                    }
                )
        else {
            return
        }

        let movedGesture =
            gestures.remove(
                at: sourceIndex
            )

        let insertionIndex: Int

        if sourceIndex < destinationIndex {
            insertionIndex = min(
                destinationIndex,
                gestures.count
            )
        } else {
            insertionIndex = destinationIndex
        }

        gestures.insert(
            movedGesture,
            at: insertionIndex
        )
    }

    func finishDragging() {
        guard draggingID != nil else {
            return
        }

        draggingID = nil
        normalizeSortOrder()
    }

    func cancelDragging() {
        draggingID = nil
    }
}


// MARK: - Sort Order

private extension DragGestureEditViewModel {

    func normalizeSortOrder(
        shouldSave: Bool = true
    ) {
        for (
            index,
            gesture
        ) in gestures.enumerated() {
            gesture.sortOrder = index
        }

        guard shouldSave else {
            return
        }

        saveModelContext()
    }
}


// MARK: - Save

private extension DragGestureEditViewModel {

    func saveModelContext() {
        guard !usesInjectedData else {
            return
        }

        guard let modelContext else {
            return
        }

        do {
            try modelContext.save()
        } catch {
            print(
                "드래그 제스처 저장 실패: \(error)"
            )
        }
    }
}


// MARK: - Modal

enum DragGestureEditModal: Identifiable {

    case add

    case edit(
        id: UUID,
        name: String,
        phrase: String
    )

    var id: String {
        switch self {
        case .add:
            return "add"

        case let .edit(id, _, _):
            return "edit-\(id.uuidString)"
        }
    }

    var title: String {
        switch self {
        case .add:
            return "드래그 제스처 추가"

        case .edit:
            return "드래그 제스처 수정"
        }
    }

    var gestureID: UUID? {
        switch self {
        case .add:
            return nil

        case let .edit(id, _, _):
            return id
        }
    }

    var existingName: String {
        switch self {
        case .add:
            return ""

        case let .edit(_, name, _):
            return name
        }
    }

    var existingPhrase: String {
        switch self {
        case .add:
            return ""

        case let .edit(_, _, phrase):
            return phrase
        }
    }
}
