//
//  FastSpeechListTestView.swift
//  Mogapa
//
//  Created by Minjae Son on 7/21/26.
//

import SwiftUI

struct FastSpeechListTestView: View {
    
    var body: some View {
        
        NavigationStack {
            
            VStack(
                spacing: 20
            ) {
                Text("빠른 말하기")
                .typography(.largeTitleBold)
                Text("전체 빠른 말하기 목록")
                .typography(.bodyMedium)
                .foregroundStyle(.textmuted)
            }
            .frame(
                maxWidth:.infinity,
                maxHeight:.infinity
            )
            .navigationTitle("빠른 말하기")
        }
    }
}

#Preview {
    FastSpeechListTestView()
}
