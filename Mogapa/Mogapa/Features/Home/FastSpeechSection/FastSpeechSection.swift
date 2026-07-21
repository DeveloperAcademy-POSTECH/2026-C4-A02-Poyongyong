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
    
    var body: some View {
        
        VStack(spacing: 12){
            header
            
            FastSpeechCategorySelector(
                categories: categories,
                selectedIndex: $selectedCategoryIndex
            )
            
            FastSpeechCardsPager(
                phrases: selectedPhrases,
                selectedPhraseID: selectedPhraseID,
                previewText: previewText,
                onPhraseSelected: onPhraseSelected
            )
        }
    }
}

private extension FastSpeechSection {
    
    var header: some View {
        
        HStack {
            Text("빠른 말하기")
                .typography(.titleBold)
                .foregroundColor(.textprimary)
            
            Spacer()
            
            Button {

            } label: {
                Image(systemName: "chevron.right")
                .font(.system(size:20))
                .foregroundColor(.textprimary)
            }
        }
        .padding(.horizontal,20)
    }
}

private extension FastSpeechSection {

    var selectedPhrases: [FastSpeechPhrase] {
        if selectedCategoryIndex == 0 {
            return recentPhrases
        }
        let categoryIndex = selectedCategoryIndex - 1
        guard categories.indices.contains(categoryIndex) else {
            return []
        }
        return categories[categoryIndex].phrases
    }
}

