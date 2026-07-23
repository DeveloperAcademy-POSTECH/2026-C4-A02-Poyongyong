//
//  FastSpeechCardsPager.swift
//  Mogapa
//
//  Created by Minjae Son on 7/20/26.
//

//
//  FastSpeechCardsPager.swift
//  Mogapa
//
//  Created by Minjae Son on 7/20/26.
//

import SwiftUI

struct FastSpeechCardsPager: View {
    
    let phrases: [FastSpeechPhrase]
    let selectedPhraseID: UUID?
    let previewText: (String) -> String
    let onPhraseSelected: (FastSpeechPhrase) -> Void
    
    private let cardHeight: CGFloat = 130
    private let spacing: CGFloat = 8
    
    private let positions: [FastSpeechCardPosition] = [
        .topLeading,
        .topTrailing,
        .bottomLeading,
        .bottomTrailing
    ]
    
    var body: some View {
        let sortedPhrases = phrases.sorted {
            $0.sortOrder < $1.sortOrder
        }
        
        if sortedPhrases.isEmpty {
            emptyState
        } else {
            let pages = sortedPhrases.chunked(
                into: 4
            )
            
            TabView {
                ForEach(
                    pages.indices,
                    id: \.self
                ) { index in
                    
                    cardPage(
                        pages[index]
                    )
                }
            }
            .tabViewStyle(
                .page(
                    indexDisplayMode:
                        pages.count > 1
                        ? .always
                        : .never
                )
            )
            .frame(
                height:
                    cardHeight * 2
                    + spacing
            )
        }
    }
}

// MARK: - Empty State

private extension FastSpeechCardsPager {
    
    var emptyState: some View {
        HStack {
            Text(
                "여기에 말한 기록이 남아요!"
            )
            .typography(
                .subTitleMedium
            )
            .foregroundStyle(
                .texttertiary
            )
            .frame(
                maxWidth: .infinity
            )
            .frame(
                minHeight: 290
            )
        }
    }
}

// MARK: - Card Page

private extension FastSpeechCardsPager {
    
    func cardPage(
        _ phrases: [FastSpeechPhrase]
    ) -> some View {
        
        let cards = Array(
            phrases.prefix(4)
        )
        
        return VStack(
            spacing: spacing
        ) {
            HStack(
                spacing: spacing
            ) {
                cardSlot(
                    at: 0,
                    cards: cards
                )
                
                cardSlot(
                    at: 1,
                    cards: cards
                )
            }
            
            HStack(
                spacing: spacing
            ) {
                cardSlot(
                    at: 2,
                    cards: cards
                )
                
                cardSlot(
                    at: 3,
                    cards: cards
                )
            }
        }
    }
}

// MARK: - Card Slot

private extension FastSpeechCardsPager {
    
    @ViewBuilder
    func cardSlot(
        at index: Int,
        cards: [FastSpeechPhrase]
    ) -> some View {
        
        if index < cards.count {
            
            let phrase = cards[index]
            
            FastSpeechCardView(
                phrase: phrase,
                position: positions[index],
                isSelected:
                    selectedPhraseID == phrase.id,
                previewText:
                    previewText(
                        phrase.text
                    ),
                onTap: {
                    onPhraseSelected(
                        phrase
                    )
                }
            )
            .frame(
                maxWidth: .infinity
            )
            
        } else {
            
            Color.clear
                .frame(
                    maxWidth: .infinity
                )
                .frame(
                    height: cardHeight
                )
        }
    }
}
// MARK: - Array Chunk

private extension Array {
    
    func chunked(
        into size: Int
    ) -> [[Element]] {
        
        guard size > 0 else {
            return []
        }
        
        return stride(
            from: 0,
            to: count,
            by: size
        )
        .map { startIndex in
            Array(
                self[
                    startIndex ..< Swift.min(
                        startIndex + size,
                        count
                    )
                ]
            )
        }
    }
}

// MARK: - Preview

#Preview {
    FastSpeechCardsPagerPreview()
}

private struct FastSpeechCardsPagerPreview: View {
    
    var body: some View {
        
        let category = FastSpeechCategory(
            name: "일상",
            sortOrder: 0
        )
        
        let phrases = [
            FastSpeechPhrase(
                text:
                    "잠시만 기다려 주세요.",
                sortOrder: 0,
                category: category
            ),
            
            FastSpeechPhrase(
                text:
                    "천천히 말씀해 주세요.",
                sortOrder: 1,
                category: category
            ),
            
            FastSpeechPhrase(
                text:
                    "제가 글로 적어서 보여드릴게요.",
                sortOrder: 2,
                category: category
            ),
            
            FastSpeechPhrase(
                text:
                    "지금 말씀을 이해하기 어려워요.",
                sortOrder: 3,
                category: category
            )
        ]
        
        FastSpeechCardsPager(
            phrases: phrases,
            selectedPhraseID:
                phrases.first?.id,
            previewText: { text in
                text
            },
            onPhraseSelected: { phrase in
                print(
                    phrase.text
                )
            }
        )
    }
}
