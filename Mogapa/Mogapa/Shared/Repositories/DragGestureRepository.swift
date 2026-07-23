//
//  DragGestureRepository.swift
//  Mogapa
//
//  Created by sun on 7/19/26.
//

import Foundation
import SwiftData

@MainActor
final class DragGestureRepository {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Read

    func fetchGestures() throws -> [RegisteredDragGesture] {
        let descriptor = FetchDescriptor<RegisteredDragGesture>()

        return try modelContext.fetch(descriptor)
    }

    func fetchGesture(
        id: UUID
    ) throws -> RegisteredDragGesture? {
        let predicate = #Predicate<RegisteredDragGesture> { gesture in
            gesture.id == id
        }

        let descriptor = FetchDescriptor<RegisteredDragGesture>(
            predicate: predicate
        )

        return try modelContext.fetch(descriptor).first
    }

    // MARK: - Create

    func insertGesture(
        _ gesture: RegisteredDragGesture
    ) throws {
        modelContext.insert(gesture)
        try save()
    }

    // MARK: - Delete

    func deleteGesture(
        _ gesture: RegisteredDragGesture
    ) throws {
        modelContext.delete(gesture)
        try save()
    }

    // MARK: - Save

    func save() throws {
        guard modelContext.hasChanges else {
            return
        }

        try modelContext.save()
    }
}
