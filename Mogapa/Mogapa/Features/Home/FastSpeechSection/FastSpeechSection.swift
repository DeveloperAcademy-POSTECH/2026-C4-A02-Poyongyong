//
//  SpeechCategorySelector.swift
//  Mogapa
//
//  Created by Minjae Son on 7/21/26.
//

import SwiftUI

struct FastSpeechSection: View {
    
    let categories: [FastSpeechCategory]
    let recentPhrases: [FastSpeechPhrase]
    
    @Binding
    var selectedCategoryIndex: Int
    
    let selectedPhraseID: UUID?
    let previewText: (String) -> String
    let onPhraseSelected: (FastSpeechPhrase) -> Void
    let onShowAllFastSpeech: () -> Void
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            sectionHeader
            
            FastSpeechCategorySelector(
                categories: categories,
                selectedIndex: $selectedCategoryIndex,
                defaultTitle: "최근 문구"
            )
            .padding(.horizontal, 10)
            
            FastSpeechCardsPager(
                phrases: selectedPhrases,
                selectedPhraseID: selectedPhraseID,
                previewText: previewText,
                onPhraseSelected: onPhraseSelected
            )
        }
    }
}

// MARK: - Header

private extension FastSpeechSection {
    
    var sectionHeader: some View {
        HStack {
            Text("빠른 말하기")
                .typography(.titleMedium)
                .foregroundStyle(.textprimary)
            
            Spacer()
            
            Button {
                onShowAllFastSpeech()
            } label: {
                HStack(spacing: 4) {
                    
                    Image(
                        systemName: "chevron.right"
                    )
                    .font(
                        .system(
                            size: 12,
                            weight: .semibold
                        )
                    )
                }
                .foregroundStyle(.textsecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Selected Phrases

private extension FastSpeechSection {
    
    var selectedPhrases: [FastSpeechPhrase] {
        
        // 0번은 최근 문구
        if selectedCategoryIndex == 0 {
            return recentPhrases.sorted {
                $0.createdAt > $1.createdAt
            }
        }
        
        /*
         화면 인덱스:
         0 = 최근 문구
         1 = categories[0]
         2 = categories[1]
         */
        let categoryIndex =
            selectedCategoryIndex - 1
        
        guard categories.indices.contains(
            categoryIndex
        ) else {
            return []
        }
        
        return categories[
            categoryIndex
        ]
        .phrases
        .sorted {
            $0.sortOrder < $1.sortOrder
        }
    }
}

// MARK: - Preview

#Preview {
    FastSpeechSectionPreview()
}

private struct FastSpeechSectionPreview: View {
    
    @State
    private var selectedCategoryIndex = 1
    
    var body: some View {
        let category = makeCategory()
        
        FastSpeechSection(
            categories: [category],
            recentPhrases: [],
            selectedCategoryIndex:
                $selectedCategoryIndex,
            selectedPhraseID: nil,
            previewText: { $0 },
            onPhraseSelected: { phrase in
                print(phrase.text)
            },
            onShowAllFastSpeech: {
                print("전체 보기")
            }
        )
        .padding()
    }
    
    private func makeCategory()
    -> FastSpeechCategory {
        
        let category = FastSpeechCategory(
            name: "일상",
            sortOrder: 0
        )
        
        let phrases = [
            FastSpeechPhrase(
                text: "잠시만 기다려 주세요.",
                sortOrder: 0,
                category: category
            ),
            FastSpeechPhrase(
                text: "천천히 말씀해 주세요.",
                sortOrder: 1,
                category: category
            )
        ]
        
        category.phrases = phrases
        
        return category
    }
}
