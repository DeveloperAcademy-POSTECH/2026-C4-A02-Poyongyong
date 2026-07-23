//
//  FastSpeechRepository.swift
//  Mogapa
//
//  Created by sun on 7/19/26.
//

import Foundation
import SwiftData

@MainActor
final class FastSpeechRepository {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Category

    func fetchCategories() throws -> [FastSpeechCategory] {
        let descriptor = FetchDescriptor<FastSpeechCategory>()

        return try modelContext.fetch(descriptor)
    }

    func insertCategory(
        _ category: FastSpeechCategory
    ) throws {
        modelContext.insert(category)
        try save()
    }

    func deleteCategory(
        _ category: FastSpeechCategory
    ) throws {
        modelContext.delete(category)
        try save()
    }

    // MARK: - Phrase

    func fetchPhrases() throws -> [FastSpeechPhrase] {
        let descriptor = FetchDescriptor<FastSpeechPhrase>()

        return try modelContext.fetch(descriptor)
    }

    func fetchPhrases(
        for category: FastSpeechCategory
    ) throws -> [FastSpeechPhrase] {
        let categoryID = category.id

        let predicate = #Predicate<FastSpeechPhrase> { phrase in
            phrase.category?.id == categoryID
        }

        let descriptor = FetchDescriptor<FastSpeechPhrase>(
            predicate: predicate
        )

        return try modelContext.fetch(descriptor)
    }

    func insertPhrase(
        _ phrase: FastSpeechPhrase
    ) throws {
        modelContext.insert(phrase)
        try save()
    }

    func deletePhrase(
        _ phrase: FastSpeechPhrase
    ) throws {
        modelContext.delete(phrase)
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
