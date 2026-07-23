//
//  FastSpeechView.swift
//  Mogapa
//
//  Created by Purple on 7/22/26.
//

import SwiftUI
import SwiftData

struct FastSpeechView: View {
    
    // MARK: - Environment
    
    @Environment(\.dismiss)
    private var dismiss
    
    @Environment(\.modelContext)
    private var modelContext
    
    
    // MARK: - SwiftData
    
    @Query(
        sort: [
            SortDescriptor(
                \FastSpeechCategory.sortOrder,
                order: .forward
            )
        ]
    )
    private var categories: [FastSpeechCategory]
    
    @Query(
        sort: [
            SortDescriptor(
                \FastSpeechPhrase.createdAt,
                order: .reverse
            )
        ]
    )
    private var phrases: [FastSpeechPhrase]
    
    
    // MARK: - State
    
    @State
    private var selectedCategoryIndex = 0

    @State
    private var isAddingCategory = false
    
    @State
    private var isEditing = false
    
    @State
    private var selectedIDs: Set<UUID> = []
    
    @State
    private var presentedModal: FastSpeechModal?

    @State
    private var categoryToDelete: FastSpeechCategory?

    @State
    private var isCategoryDeleteAlertPresented = false
    
    
    // MARK: - Body
    
    var body: some View {
        ZStack(
            alignment: .bottomTrailing
        ) {
            VStack(spacing: 18) {
                header
                
                FastSpeechCategorySelector(
                    categories: categories,
                    selectedIndex:
                        $selectedCategoryIndex,
                    defaultTitle: "최근 문구",
                    showsAddButton: true,
                    isEditing: isEditing,
                    onAddCategory: addCategory,
                    onAddingStateChange: { isAdding in
                        withAnimation(.snappy) {
                            isAddingCategory = isAdding
                        }
                    },
                    onDeleteCategory: presentDeleteCategoryAlert
                )
                .padding(.horizontal, 20)
                
                ZStack(alignment: .top) {
                    QuickSpeechBubbleList(
                        items: bubbleItems,
                        isEditing: isEditing,
                        selectedIDs: $selectedIDs,
                        onTap: { id in
                            guard let phrase = phrases.first(
                                where: {
                                    $0.id == id
                                }
                            ) else {
                                return
                            }
                            
                            presentedModal = .edit(
                                phrase.id,
                                phrase.text
                            )
                        },
                        onDelete: {
                            deletePhrase($0)
                        }
                    )

                    if showsEmptyCategoryMessage {
                        emptyCategoryMessage
                    }
                }
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
        .background(
            .backgroundbgCanvas
        )
        .navigationBarBackButtonHidden(true)
        .toolbar(
            .hidden,
            for: .navigationBar
        )
        .onChange(
            of: categories.count
        ) { _, count in
            adjustSelectedCategoryIndex(
                categoryCount: count
            )
        }
        .sheet(
            item: $presentedModal
        ) { modal in
            SpeechModalContent(
                title: modal.title,
                categories: categoryNames,
                existingText: modal.existingText,
                initialCategory: modal.initialCategory(
                    currentCategoryName:
                        currentCategoryName,
                    fallbackCategoryName:
                        categoryNames.first
                ),
                onConfirm: { text, categoryName in
                    handleModalConfirm(
                        modal,
                        text: text,
                        categoryName: categoryName
                    )
                }
            )
        }
        .customAlert(
            isPresented: $isCategoryDeleteAlertPresented,
            title: categoryDeleteAlertTitle,
            message: "카테고리 내 문구들도 한번에 지워집니다.",
            onConfirm: {
                confirmDeleteCategory()
            }
        )
        .onChange(
            of: selectedCategoryIndex
        ) { _, _ in
            selectedIDs.removeAll()
        }
    }
}

// MARK: - Header

private extension FastSpeechView {
    
    var header: some View {
        MogapaNavigationHeader(
            title: "빠른 말하기",
            rightTitle:
                isEditing ? nil : "편집",
            rightSystemImage:
                isEditing ? "trash.fill" : nil,
            isRightDisabled:
                isEditing && selectedIDs.isEmpty,
            isRightProminent:
                isEditing && !selectedIDs.isEmpty,
            rightTint:
                isEditing && !selectedIDs.isEmpty
                ? .accentsRed
                : .clear,
            rightForegroundStyle:
                rightForegroundStyle,
            leftTitle:
                isEditing ? "취소" : nil,
            leftIcon:
                isEditing
                ? nil
                : "chevron.left",
            leftAccessibilityLabel:
                isEditing
                ? "편집 종료"
                : "뒤로 가기",
            onLeftTap:
                handleLeftTap,
            onRightTap:
                handleRightTap
        )
    }

    var rightForegroundStyle: AnyShapeStyle {
        if !isEditing {
            return AnyShapeStyle(.textsecondary)
        }

        return selectedIDs.isEmpty
            ? AnyShapeStyle(.textmuted)
            : AnyShapeStyle(.iconinverse)
    }

    var emptyCategoryMessage: some View {
        Text("+ 버튼을 눌러 빠른 말하기를 추가해보세요")
            .typography(.bodyMedium)
            .foregroundStyle(.textmuted)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 72)
            .allowsHitTesting(false)
    }

    var categoryDeleteAlertTitle: String {
        guard let categoryName = categoryToDelete?.name else {
            return "카테고리를 삭제할까요?"
        }

        return "\(categoryName) 카테고리를 삭제할까요?"
    }
}

// MARK: - Categories

private extension FastSpeechView {
    
    var categoryNames: [String] {
        categories.map(\.name)
    }

    var currentCategoryName: String? {
        let categoryIndex =
            selectedCategoryIndex - 1

        guard categories.indices.contains(
            categoryIndex
        ) else {
            return nil
        }

        return categories[categoryIndex].name
    }

    var showsEmptyCategoryMessage: Bool {
        (selectedCategoryIndex > 0 || isAddingCategory) &&
            filteredPhrases.isEmpty
    }
    
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
}

// MARK: - Filtered Phrases

private extension FastSpeechView {
    
    var filteredPhrases: [FastSpeechPhrase] {
        
        // 0번 탭: category가 없는 최근 문구
        if selectedCategoryIndex == 0 {
            return phrases
                .filter {
                    $0.category == nil
                }
                .sorted {
                    $0.createdAt > $1.createdAt
                }
        }
        
        // 화면 인덱스에서 최근 탭 제외
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
                return $0.sortOrder <
                    $1.sortOrder
            }
    }
}

// MARK: - Bubble Items

private extension FastSpeechView {
    
    var bubbleItems:
    [QuickSpeechBubbleListItem<UUID>] {
        filteredPhrases.map(
            quickSpeechBubbleItem
        )
    }
    
    func quickSpeechBubbleItem(
        _ phrase: FastSpeechPhrase
    ) -> QuickSpeechBubbleListItem<UUID> {
        QuickSpeechBubbleListItem(
            id: phrase.id,
            text: phrase.text
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

// MARK: - SwiftData Actions

private extension FastSpeechView {
    
    func addCategory(_ name: String) {
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

            withAnimation(.snappy) {
                selectedCategoryIndex = 1
            }
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

    func confirmDeleteCategory() {
        guard let category = categoryToDelete else {
            return
        }

        deleteCategory(category)
        categoryToDelete = nil
    }

    func deleteCategory(
        _ category: FastSpeechCategory
    ) {
        let nextSelectedIndex =
            nextSelectedCategoryIndexAfterDeleting(
                category
            )

        do {
            withAnimation(.snappy) {
                selectedCategoryIndex = nextSelectedIndex
                selectedIDs.removeAll()
                modelContext.delete(category)
            }

            try modelContext.save()
        } catch {
            print(
                "빠른 말하기 카테고리 삭제 실패: \(error)"
            )
        }
    }

    func nextSelectedCategoryIndexAfterDeleting(
        _ category: FastSpeechCategory
    ) -> Int {
        guard let deletingIndex = categories.firstIndex(
            where: {
                $0.id == category.id
            }
        ) else {
            return selectedCategoryIndex
        }

        if deletingIndex < categories.count - 1 {
            return deletingIndex + 1
        }

        return max(0, deletingIndex)
    }

    func addPhrase(
        text: String,
        categoryName: String
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
                for: category
            ),
            category: category
        )

        withAnimation(.snappy) {
            modelContext.insert(phrase)
        }

        saveModelContext()
    }

    func updatePhrase(
        id: UUID,
        text: String,
        categoryName: String
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

        withAnimation(.snappy) {
            phrase.text = text
            phrase.category = category
        }

        saveModelContext()
    }

    func nextPhraseSortOrder(
        for category: FastSpeechCategory
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

    func deletePhrase(
        _ id: UUID
    ) {
        guard let phrase = phrases.first(
            where: {
                $0.id == id
            }
        ) else {
            return
        }
        
        withAnimation(.snappy) {
            selectedIDs.remove(id)
            modelContext.delete(phrase)
        }
        
        saveModelContext()
    }
    
    func deleteSelectedPhrases() {
        guard !selectedIDs.isEmpty else {
            return
        }
        
        let phrasesToDelete =
            phrases.filter {
                selectedIDs.contains(
                    $0.id
                )
            }
        
        withAnimation(.snappy) {
            for phrase in phrasesToDelete {
                modelContext.delete(phrase)
            }
            
            selectedIDs.removeAll()
            isEditing = false
        }
        
        saveModelContext()
    }
    
    func saveModelContext() {
        do {
            try modelContext.save()
        } catch {
            print(
                "빠른 말하기 저장 실패: \(error)"
            )
        }
    }
}

// MARK: - Modal Actions

private extension FastSpeechView {

    func handleModalConfirm(
        _ modal: FastSpeechModal,
        text: String,
        categoryName: String
    ) {
        switch modal {
        case .add:
            addPhrase(
                text: text,
                categoryName: categoryName
            )

        case let .edit(id, _):
            updatePhrase(
                id: id,
                text: text,
                categoryName: categoryName
            )
        }
    }
}

// MARK: - Modal

private enum FastSpeechModal: Identifiable {
    
    case add
    case edit(UUID, String)
    
    var id: String {
        switch self {
        case .add:
            return "add"
            
        case let .edit(id, _):
            return "edit-\(id.uuidString)"
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
            
        case let .edit(_, text):
            return text
        }
    }

    func initialCategory(
        currentCategoryName: String?,
        fallbackCategoryName: String?
    ) -> String? {
        switch self {
        case .add:
            return currentCategoryName
                ?? fallbackCategoryName

        case .edit:
            return currentCategoryName
                ?? fallbackCategoryName
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FastSpeechView()
    }
    .modelContainer(
        for: [
            FastSpeechCategory.self,
            FastSpeechPhrase.self
        ],
        inMemory: true
    )
    .environment(
        \.locale,
        Locale(identifier: "ko")
    )
}
