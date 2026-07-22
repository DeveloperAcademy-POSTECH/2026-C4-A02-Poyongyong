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
        
        let sortedPhrases = phrases.sorted {
            $0.sortOrder < $1.sortOrder
        }
        if sortedPhrases.isEmpty {
            emptyState
        } else {
            let pages = sortedPhrases.chunked(into: 4)
            
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
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
    }
}

private extension FastSpeechCardsPager {
    
    var emptyState: some View {
        HStack(alignment: .center){
            Text("여기에 말한 기록이 남아요!")
                .typography(.subTitleMedium)
                .foregroundStyle(.texttertiary)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 290)
        }
    }
}

private extension FastSpeechCardsPager {

    func cardPage(
        _ phrases: [FastSpeechPhrase]
    ) -> some View {

        LazyVGrid(columns: columns, spacing: 8)
        {
            ForEach(
                0..<4,
                id: \.self
            ) { index in
                if index < phrases.count {
                    let phrase = phrases[index]
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
                } else {
                    Color.clear
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 150, maxHeight: 170)
                }
            }
        }
    }
}

private extension Array {
    
    func chunked(
        into size: Int
    ) -> [[Element]] {
        
        stride(
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

//#Preview {
//    FastSpeechCardsPager(
//        category: FastSpeechCategory(
//            name: "일상",
//            sortOrder: 0
//        ),
//        selectedPhraseID: nil,
//        previewText: { $0 },
//        onPhraseSelected: { _ in }
//    )
//}

#Preview {
    FastSpeechCardsPagerPreview()
}

private struct FastSpeechCardsPagerPreview: View {
    
    var body: some View {
        
        let phrases = [
            FastSpeechPhrase(
                text: "잠시만 기다려 주세요.",
                sortOrder: 0
            ),
            FastSpeechPhrase(
                text: "천천히 말씀해 주세요.",
                sortOrder: 1
            )
        ]
        
        FastSpeechCardsPager(
            phrases: phrases,
            selectedPhraseID: nil,
            previewText: { text in
                text
            },
            onPhraseSelected: { phrase in
                print(phrase.text)
            }
        )
    }
}
