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
    
    @Published
    var selectedPhraseID: UUID?
    
    // 0번은 최근 문구, 1번부터 실제 카테고리
    @Published
    var selectedCategoryIndex: Int = 1
    
    
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
        
        selectedPhraseID = nil
    }
    
    
    // MARK: - Category Selection
    
    func selectCategory(
        at index: Int
    ) {
        guard index >= 0 else {
            return
        }
        
        selectedCategoryIndex = index
        
        // 다른 카테고리로 이동하면 기존 카드 선택 해제
        selectedPhraseID = nil
        inputText = ""
    }
    
    
    // MARK: - Fast Speech Card Selection
    
    func selectPhrase(
        _ phrase: FastSpeechPhrase
    ) {
        if selectedPhraseID == phrase.id {
            selectedPhraseID = nil
            inputText = ""
            return
        }
        
        selectedPhraseID = phrase.id
        inputText = String(
            phrase.text.prefix(
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
        
        guard words.count > maximumPreviewWordCount else {
            return text
        }
        
        return words
            .prefix(maximumPreviewWordCount)
            .joined(separator: " ") + "..."
    }
}
