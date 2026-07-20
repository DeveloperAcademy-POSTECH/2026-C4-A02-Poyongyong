//
//  FastSpeechCardsPager.swift
//  Mogapa
//
//  Created by Minjae Son on 7/20/26.
//

import SwiftUI

struct FastSpeechCardsPager: View {
    
    let category: FastSpeechCategory
    let selectedPhraseID: UUID?
    let previewText: (String) -> String
    let onPhraseSelected:
    (FastSpeechPhrase) -> Void
    private let columns = [
        GridItem(
            .flexible(),
            spacing: 8
        ),
        GridItem(
            .flexible(),
            spacing: 8
        )
    ]
    
    private let positions: [
        FastSpeechCardPosition
    ] = [
        .topLeading,
        .topTrailing,
        .bottomLeading,
        .bottomTrailing
    ]
    
    var body: some View {
        
        let phrases =
        category.phrases
            .sorted {
                $0.sortOrder < $1.sortOrder
            }
        if phrases.isEmpty {
            emptyState
        } else {
            
            let pages =
            phrases.chunked(
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
                    indexDisplayMode: .always
                )
            )
        }
    }
}

private extension FastSpeechCardsPager {
    
    var emptyState: some View {
        
        Text("여기에 말한 기록이 남아요!")
            .typography(.title2Medium)
            .foregroundStyle(.texttertiary)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 308)
    }
}

private extension FastSpeechCardsPager {
    
    func cardPage(
        _ phrases: [FastSpeechPhrase]
    ) -> some View {
        
        LazyVGrid(
            columns:
                columns,
            spacing:
                8
        ) {
            ForEach(
                Array(
                    phrases.enumerated()
                ),
                id:
                    \.element.id
                
            ) { index, phrase in
                
                FastSpeechCardView(
                    phrase:
                        phrase,
                    
                    position:
                        positions[index],
                    
                    isSelected:
                        selectedPhraseID
                    == phrase.id,
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
            }
        }
        .padding(.horizontal, 20)
    }
}

private extension Array {
    
    func chunked(
        into size: Int
    ) -> [[Element]] {

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

#Preview {
    FastSpeechCardsPager(
        category: FastSpeechCategory(
            name: "일상",
            sortOrder: 0
        ),
        selectedPhraseID: nil,
        previewText: { $0 },
        onPhraseSelected: { _ in }
    )
}

//#Preview {
//    let category = FastSpeechCategory(
//        name: "일상",
//        sortOrder: 0
//    )
//
//    category.phrases = [
//        FastSpeechPhrase(
//            text: "잠시만 기다려 주세요.",
//            sortOrder: 0
//        ),
//        FastSpeechPhrase(
//            text: "천천히 말씀해 주세요.",
//            sortOrder: 1
//        )
//    ]
//
//    return FastSpeechCardsPager(
//        category: category,
//        selectedPhraseID: nil,
//        previewText: { $0 },
//        onPhraseSelected: { _ in }
//    )
//}
