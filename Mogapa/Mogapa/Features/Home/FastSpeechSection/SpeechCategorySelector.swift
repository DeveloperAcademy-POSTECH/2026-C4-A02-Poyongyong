//
//  SpeechCategorySelector.swift
//  Mogapa
//
//  Created by Minjae Son on 7/21/26.
//

import SwiftUI

struct FastSpeechCategorySelector: View {
    
    let categories: [FastSpeechCategory]
    
    @Binding
    var selectedIndex: Int
    
    var body: some View {
        
        ScrollView(
            .horizontal,
            showsIndicators: false
        ) {
            HStack(spacing: 8)
            {
                CategoryLabel(
                    title: "최근순",
                    isSelected:
                        selectedIndex == 0
                ) {
                    selectedIndex = 0
                }
                
                ForEach(
                    Array(categories.enumerated()),
                    id:\.element.id
                ) { index, category in
                    CategoryLabel(
                        title:
                            category.name,
                        isSelected:
                            selectedIndex
                        == index + 1
                    ) {
                        selectedIndex =
                        index + 1
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity,alignment: .leading)
    }
}

#Preview {
    @Previewable @State var selectedIndex = 0
    
    FastSpeechCategorySelector(
        categories: [
            FastSpeechCategory(
                name: "직장",
                sortOrder: 0
            ),
            
            FastSpeechCategory(
                name: "병원",
                sortOrder: 1
            ),
            
            FastSpeechCategory(
                name: "일상",
                sortOrder: 2
            )],
        selectedIndex: $selectedIndex
    )
}
