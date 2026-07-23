//
//  FastSpeechCardView.swift
//  Mogapa
//
//  Created by Minjae Son on 7/20/26.
//

import SwiftUI

enum FastSpeechCardPosition {
    
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
}

struct FastSpeechCardView: View {
    
    let phrase: FastSpeechPhrase
    let position:FastSpeechCardPosition
    let isSelected: Bool
    let previewText: String
    let onTap: () -> Void
    
    var body: some View {
        
        Button {
            onTap()
        } label: {
            cardContent
        }
        .buttonStyle(
            .plain
        )
    }
}

private extension FastSpeechCardView {
    
    var cardContent: some View {
        
        ZStack {
            
            cardBackground
            
            VStack{
                Text(previewText)
                    .typography(.bodyRegular)
                    .foregroundColor(.textsecondary)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .topLeading

                    )
            }
            .padding(24)
            
            if isSelected {
                Image(systemName: "arrow.trianglehead.clockwise")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.iconinverse)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 130)
        .animation(
            .easeInOut(duration: 0.2),
            value: isSelected
        )
    }
}


// MARK: - Background

private extension FastSpeechCardView {
    
    @ViewBuilder
    var cardBackground: some View {
        
        let backgroundColor = isSelected ? Color.backgroundbgCardSelected : Color.backgroundbgCard
        
        switch position {
            
        case .topLeading:
            UnevenRoundedRectangle(
                cornerRadii:
                        .init(
                            topLeading: 40,
                            bottomLeading: 40,
                            bottomTrailing: 0,
                            topTrailing: 40
                        )
            )
            .fill(backgroundColor)
            
        case .topTrailing:
            UnevenRoundedRectangle(
                cornerRadii:
                        .init(
                            topLeading: 40,
                            bottomLeading: 0,
                            bottomTrailing: 40,
                            topTrailing: 40
                        )
            )
            .fill(backgroundColor)
            
        case .bottomLeading:
            UnevenRoundedRectangle(
                cornerRadii:
                        .init(
                            topLeading: 40,
                            bottomLeading: 40,
                            bottomTrailing: 40,
                            topTrailing: 0
                        )
            )
            .fill(backgroundColor)
            
        case .bottomTrailing:
            UnevenRoundedRectangle(
                cornerRadii:
                        .init(
                            topLeading: 0,
                            bottomLeading: 40,
                            bottomTrailing: 40,
                            topTrailing: 40
                        )
            )
            .fill(backgroundColor)
        }
    }
}

#Preview("One Selected Card") {
    
    let phrases = [
        FastSpeechPhrase(
            text: "빠른 말하기 페이지에서 삭제 후 사용하세요!",
            sortOrder: 0
        ),
        
        FastSpeechPhrase(
            text: "지금 말씀을 이해하기 어려워요.",
            sortOrder: 1
        ),
        
        FastSpeechPhrase(
            text: "천천히 말씀해 주실 수 있을까요?",
            sortOrder: 2
        ),
        
        FastSpeechPhrase(
            text: "제가 글로 적어서 보여드릴게요.",
            sortOrder: 3
        )
    ]
    
    LazyVGrid(
        columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    ) {
        
        FastSpeechCardView(
            phrase: phrases[0],
            position: .topLeading,
            isSelected: false,
            previewText: phrases[0].text,
            onTap: {
                print("Card 1 tapped")
            }
        )
        
        FastSpeechCardView(
            phrase: phrases[1],
            position: .topTrailing,
            isSelected: true,
            previewText: phrases[1].text,
            onTap: {
                print("Card 2 tapped")
            }
        )
        
        FastSpeechCardView(
            phrase: phrases[2],
            position: .bottomLeading,
            isSelected: false,
            previewText: phrases[2].text,
            onTap: {
                print("Card 3 tapped")
            }
        )
        
        FastSpeechCardView(
            phrase: phrases[3],
            position: .bottomTrailing,
            isSelected: false,
            previewText: phrases[3].text,
            onTap: {
                print("Card 4 tapped")
            }
        )
    }
    .padding()
}
