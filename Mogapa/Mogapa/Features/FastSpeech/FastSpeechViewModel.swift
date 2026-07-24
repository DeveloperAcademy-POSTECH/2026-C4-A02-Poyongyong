//
//  FastSpeechViewModel.swift
//  Mogapa
//
//  Created by sun on 7/24/26.
//

import Foundation
import Observation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class FastSpeechViewModel {

    // MARK: - State

    var selectedCategoryIndex = 0
    var isAddingCategory = false
    var isEditing = false
    var selectedIDs: Set<UUID> = []

    var presentedModal: FastSpeechModal?
    var categoryToDelete: FastSpeechCategory?
    var isCategoryDeleteAlertPresented = false

    // MARK: - UI State

    var categoryDeleteAlertTitle: String {
        guard let categoryName = categoryToDelete?.name else {
            return "카테고리를 삭제할까요?"
        }

        return "\(categoryName) 카테고리를 삭제할까요?"
    }

    var canMoveSelectedPhrases: Bool {
        selectedCategoryIndex != 0
    }

    func categoryNames(
        from categories: [FastSpeechCategory]
    ) -> [String] {
        categories.map(\.name)
    }

    func currentCategoryName(
        from categories: [FastSpeechCategory]
    ) -> String? {
        let categoryIndex =
            selectedCategoryIndex - 1

        guard categories.indices.contains(
            categoryIndex
        ) else {
            return nil
        }

        return categories[categoryIndex].name
    }

    func showsEmptyCategoryMessage(
        categories: [FastSpeechCategory],
        phrases: [FastSpeechPhrase]
    ) -> Bool {
        let filteredPhrases = filteredPhrases(
            categories: categories,
            phrases: phrases
        )

        return (
            selectedCategoryIndex > 0 ||
            isAddingCategory
        ) && filteredPhrases.isEmpty
    }

    // MARK: - Category Selection

    func adjustSelectedCategoryIndex(
        categoryCount: Int
    ) {
        /*
         0 = 최근 문구
         1 = categories[0]
         2 = categories[1]
         */

        guard selectedCategoryIndex <= categoryCount else {
            selectedCategoryIndex = 0
            return
        }
    }

    func selectCategoryChanged() {
        selectedIDs.removeAll()
    }

    func updateAddingCategoryState(
        _ isAdding: Bool
    ) {
        isAddingCategory = isAdding
    }

    // MARK: - Filtering

    func filteredPhrases(
        categories: [FastSpeechCategory],
        phrases: [FastSpeechPhrase]
    ) -> [FastSpeechPhrase] {
        if selectedCategoryIndex == 0 {
            return phrases
                .filter {
                    $0.category == nil
                }
                .sorted {
                    $0.createdAt > $1.createdAt
                }
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

        return phrases
            .filter {
                $0.category?.id ==
                    selectedCategoryID
            }
            .sorted {
                $0.sortOrder <
                    $1.sortOrder
            }
    }

    func bubbleItems(
        categories: [FastSpeechCategory],
        phrases: [FastSpeechPhrase]
    ) -> [QuickSpeechBubbleListItem<UUID>] {
        filteredPhrases(
            categories: categories,
            phrases: phrases
        )
        .map {
            QuickSpeechBubbleListItem(
                id: $0.id,
                text: $0.text
            )
        }
    }

    // MARK: - Editing

    func startEditing() {
        isEditing = true
    }

    func cancelEditing() {
        isEditing = false
        selectedIDs.removeAll()
    }

    // MARK: - Modal

    func presentAddModal() {
        presentedModal = .add
    }

    func presentEditModal(
        phraseID: UUID,
        phrases: [FastSpeechPhrase]
    ) {
        guard let phrase = phrases.first(
            where: {
                $0.id == phraseID
            }
        ) else {
            return
        }

        presentedModal = .edit(
            phrase.id,
            phrase.text
        )
    }

    func initialCategoryName(
        for modal: FastSpeechModal,
        categories: [FastSpeechCategory]
    ) -> String? {
        modal.initialCategory(
            currentCategoryName:
                currentCategoryName(
                    from: categories
                ),
            fallbackCategoryName:
                categoryNames(
                    from: categories
                ).first
        )
    }

    // MARK: - Category CRUD

    func addCategory(
        _ name: String,
        categories: [FastSpeechCategory],
        modelContext: ModelContext
    ) {
        let firstSortOrder =
            categories
                .map(\.sortOrder)
                .min()
            ?? 0

        let category = FastSpeechCategory(
            name: name,
            sortOrder:
                categories.isEmpty
                ? 0
                : firstSortOrder - 1
        )

        do {
            try FastSpeechRepository(
                modelContext: modelContext
            )
            .insertCategory(category)

            selectedCategoryIndex = 1
        } catch {
            print(
                "빠른 말하기 카테고리 추가 실패: \(error)"
            )
        }
    }

    func presentDeleteCategoryAlert(
        _ category: FastSpeechCategory
    ) {
        categoryToDelete = category
        isCategoryDeleteAlertPresented = true
    }

    func confirmDeleteCategory(
        categories: [FastSpeechCategory],
        modelContext: ModelContext
    ) {
        guard let category = categoryToDelete else {
            return
        }

        deleteCategory(
            category,
            categories: categories,
            modelContext: modelContext
        )

        categoryToDelete = nil
    }

    func deleteCategory(
        _ category: FastSpeechCategory,
        categories: [FastSpeechCategory],
        modelContext: ModelContext
    ) {
        selectedCategoryIndex =
            nextSelectedCategoryIndexAfterDeleting(
                category,
                categories: categories
            )

        selectedIDs.removeAll()
        modelContext.delete(category)

        saveModelContext(modelContext)
    }

    private func nextSelectedCategoryIndexAfterDeleting(
        _ category: FastSpeechCategory,
        categories: [FastSpeechCategory]
    ) -> Int {
        guard let deletingIndex =
            categories.firstIndex(
                where: {
                    $0.id == category.id
                }
            )
        else {
            return selectedCategoryIndex
        }

        if deletingIndex < categories.count - 1 {
            return deletingIndex + 1
        }

        return max(0, deletingIndex)
    }

    // MARK: - Phrase CRUD

    func handleModalConfirm(
        _ modal: FastSpeechModal,
        text: String,
        categoryName: String,
        categories: [FastSpeechCategory],
        phrases: [FastSpeechPhrase],
        modelContext: ModelContext
    ) {
        switch modal {
        case .add:
            addPhrase(
                text: text,
                categoryName: categoryName,
                categories: categories,
                phrases: phrases,
                modelContext: modelContext
            )

        case let .edit(id, _):
            updatePhrase(
                id: id,
                text: text,
                categoryName: categoryName,
                categories: categories,
                phrases: phrases,
                modelContext: modelContext
            )
        }
    }

    func addPhrase(
        text: String,
        categoryName: String,
        categories: [FastSpeechCategory],
        phrases: [FastSpeechPhrase],
        modelContext: ModelContext
    ) {
        guard let category = categories.first(
            where: {
                $0.name == categoryName
            }
        ) else {
            return
        }

        let phrase = FastSpeechPhrase(
            text: text,
            sortOrder: nextPhraseSortOrder(
                for: category,
                phrases: phrases
            ),
            category: category
        )

        modelContext.insert(phrase)
        saveModelContext(modelContext)
    }

    func updatePhrase(
        id: UUID,
        text: String,
        categoryName: String,
        categories: [FastSpeechCategory],
        phrases: [FastSpeechPhrase],
        modelContext: ModelContext
    ) {
        guard
            let phrase = phrases.first(
                where: {
                    $0.id == id
                }
            ),
            let category = categories.first(
                where: {
                    $0.name == categoryName
                }
            )
        else {
            return
        }

        phrase.text = text
        phrase.category = category

        saveModelContext(modelContext)
    }

    func deletePhrase(
        _ id: UUID,
        phrases: [FastSpeechPhrase],
        modelContext: ModelContext
    ) {
        guard let phrase = phrases.first(
            where: {
                $0.id == id
            }
        ) else {
            return
        }

        selectedIDs.remove(id)
        modelContext.delete(phrase)

        saveModelContext(modelContext)
    }

    func deleteSelectedPhrases(
        phrases: [FastSpeechPhrase],
        modelContext: ModelContext
    ) {
        guard !selectedIDs.isEmpty else {
            return
        }

        let phrasesToDelete =
            phrases.filter {
                selectedIDs.contains($0.id)
            }

        for phrase in phrasesToDelete {
            modelContext.delete(phrase)
        }

        selectedIDs.removeAll()
        isEditing = false

        saveModelContext(modelContext)
    }

    func movePhrases(
        from source: IndexSet,
        to destination: Int,
        categories: [FastSpeechCategory],
        phrases: [FastSpeechPhrase],
        modelContext: ModelContext
    ) {
        guard canMoveSelectedPhrases else {
            return
        }

        var reorderedPhrases =
            filteredPhrases(
                categories: categories,
                phrases: phrases
            )

        reorderedPhrases.move(
            fromOffsets: source,
            toOffset: destination
        )

        for (index, phrase) in
            reorderedPhrases.enumerated() {
            phrase.sortOrder = index
        }

        saveModelContext(modelContext)
    }

    private func nextPhraseSortOrder(
        for category: FastSpeechCategory,
        phrases: [FastSpeechPhrase]
    ) -> Int {
        let categoryID = category.id

        return (
            phrases
                .filter {
                    $0.category?.id == categoryID
                }
                .map(\.sortOrder)
                .max()
            ?? -1
        ) + 1
    }

    private func saveModelContext(
        _ modelContext: ModelContext
    ) {
        do {
            try modelContext.save()
        } catch {
            print(
                "빠른 말하기 저장 실패: \(error)"
            )
        }
    }
}

// MARK: - Modal

extension FastSpeechViewModel {

    enum FastSpeechModal: Identifiable {

        case add
        case edit(UUID, String)

        var id: String {
            switch self {
            case .add:
                "add"

            case let .edit(id, _):
                "edit-\(id.uuidString)"
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

            case let .edit(_, text):
                text
            }
        }

        func initialCategory(
            currentCategoryName: String?,
            fallbackCategoryName: String?
        ) -> String? {
            currentCategoryName ??
                fallbackCategoryName
        }
    }
}
