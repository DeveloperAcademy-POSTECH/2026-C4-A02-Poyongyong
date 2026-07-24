//
//  HomeViewModel.swift
//  Mogapa
//
//  Created by Minjae Son on 7/21/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    
    // MARK: - Text Input
    
    @Published
    var inputText: String = ""
    
    @Published
    var isTextFieldExpanded: Bool = false
    
    
    // MARK: - Fast Speech Selection
    
    // 여러 개의 빠른 문구 선택 가능
    @Published
    var selectedPhrases: [FastSpeechPhrase] = []
    
    // 0번은 최근 문구, 1번부터 실제 카테고리
    @Published
    var selectedCategoryIndex: Int = 0
    
    
    // MARK: - Constants
    
    let maximumCharacterCount: Int = 150
    
    let maximumPreviewWordCount: Int = 20
    
    
    // MARK: - Character Count
    
    var characterCount: Int {
        inputText.count
    }
    
    
    // MARK: - Text Input
    
    func openTextInput() {
        isTextFieldExpanded = true
    }
    
    func closeTextInput() {
        isTextFieldExpanded = false
    }
    
    func updateText(
        _ newText: String
    ) {
        if newText.count <= maximumCharacterCount {
            inputText = newText
        } else {
            inputText = String(
                newText.prefix(
                    maximumCharacterCount
                )
            )
        }
        
        // 직접 입력하면 빠른 문구 선택 해제
        selectedPhrases.removeAll()
    }
    
    
    // MARK: - Category Selection
    
    func selectCategory(
        at index: Int
    ) {
        guard index >= 0 else {
            return
        }
        
        selectedCategoryIndex = index
        
        // 다른 카테고리로 이동하면 기존 선택 해제
        selectedPhrases.removeAll()
        inputText = ""
    }
    
    
    // MARK: - Fast Speech Card Selection
    
    func selectPhrase(
        _ phrase: FastSpeechPhrase
    ) {
        
        if let index = selectedPhrases.firstIndex(
            where: {
                $0.id == phrase.id
            }
        ) {
            
            // 이미 선택된 카드 → 제거
            selectedPhrases.remove(
                at: index
            )
            
        } else {
            
            // 선택되지 않은 카드 → 추가
            selectedPhrases.append(
                phrase
            )
        }
        
        rebuildSelectedPhraseText()
    }
    
    
    private func rebuildSelectedPhraseText() {
        
        let combinedText = selectedPhrases
            .map(\.text)
            .joined(
                separator: " "
            )
        
        inputText = String(
            combinedText.prefix(
                maximumCharacterCount
            )
        )
    }
    
    
    // MARK: - Card Preview
    
    func previewText(
        for text: String
    ) -> String {
        let words = text.split {
            $0.isWhitespace
        }
        
        guard words.count <= maximumPreviewWordCount else {
            return text
        }
        
        return words
            .prefix(maximumPreviewWordCount)
            .joined(separator: " ")
            + "..."
    }
}
