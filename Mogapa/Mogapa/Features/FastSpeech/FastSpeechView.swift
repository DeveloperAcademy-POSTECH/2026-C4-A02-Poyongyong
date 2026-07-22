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
    private var isEditing = false
    
    @State
    private var selectedIDs: Set<UUID> = []
    
    @State
    private var presentedModal: FastSpeechModal?
    
    
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
                    defaultTitle: "최근 말하기",
                    showsAddButton: true,
                    onAddCategory: addCategory
                )
                .padding(.horizontal, 20)
                
                QuickSpeechBubbleList(
                    sections: bubbleSections,
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
                    onPin: {
                        updatePinnedState(
                            for: $0,
                            isPinned: true
                        )
                    },
                    onUnpin: {
                        updatePinnedState(
                            for: $0,
                            isPinned: false
                        )
                    },
                    onDelete: {
                        deletePhrase($0)
                    }
                )
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
                existingText: modal.existingText
            )
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
            rightTint:
                isEditing
                ? .accentsRed
                : .clear,
            rightForegroundStyle:
                isEditing
                ? .iconinverse
                : .textsecondary,
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
}

// MARK: - Categories

private extension FastSpeechView {
    
    var categoryNames: [String] {
        categories.map(\.name)
    }
    
    func adjustSelectedCategoryIndex(
        categoryCount: Int
    ) {
        /*
         0 = 최근 말하기
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
                if $0.isPinned != $1.isPinned {
                    return $0.isPinned &&
                        !$1.isPinned
                }
                
                return $0.sortOrder <
                    $1.sortOrder
            }
    }
}

// MARK: - Bubble Sections

private extension FastSpeechView {
    
    var bubbleSections:
    [QuickSpeechBubbleListSection<UUID>] {
        
        let pinnedItems =
            filteredPhrases
                .filter(\.isPinned)
                .map(
                    quickSpeechBubbleItem
                )
        
        let normalItems =
            filteredPhrases
                .filter {
                    !$0.isPinned
                }
                .map(
                    quickSpeechBubbleItem
                )
        
        if selectedCategoryIndex == 0 {
            guard !pinnedItems.isEmpty else {
                return [
                    QuickSpeechBubbleListSection(
                        title: "최신순",
                        items: normalItems
                    )
                ]
            }
            
            return [
                QuickSpeechBubbleListSection(
                    title: "고정됨",
                    items: pinnedItems
                ),
                QuickSpeechBubbleListSection(
                    title: "최신순",
                    items: normalItems
                )
            ]
        }
        
        guard !pinnedItems.isEmpty else {
            return [
                QuickSpeechBubbleListSection(
                    items: normalItems
                )
            ]
        }
        
        return [
            QuickSpeechBubbleListSection(
                title: "고정됨",
                items: pinnedItems
            ),
            QuickSpeechBubbleListSection(
                items: normalItems
            )
        ]
    }
    
    func quickSpeechBubbleItem(
        _ phrase: FastSpeechPhrase
    ) -> QuickSpeechBubbleListItem<UUID> {
        QuickSpeechBubbleListItem(
            id: phrase.id,
            text: phrase.text,
            isPinned: phrase.isPinned
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
    
    func updatePinnedState(
        for id: UUID,
        isPinned: Bool
    ) {
        guard let phrase = phrases.first(
            where: {
                $0.id == id
            }
        ) else {
            return
        }
        
        withAnimation(.snappy) {
            phrase.isPinned = isPinned
        }
        
        saveModelContext()
    }

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
