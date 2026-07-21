//
//  SpeechTestView.swift
//  Mogapa
//
//  Created by Minjae Son on 7/21/26.
//

import SwiftUI

struct SpeechTestView: View {
    
    let text: String
    
    var body: some View {
        
        VStack(spacing: 20)
        {
            Text("Speech Button Test")
                .typography(.largeTitleBold)
            Text(text.isEmpty ? "입력된 문장이 없습니다." : text)
            .typography(.bodyMedium)
            .multilineTextAlignment(.center)
            
            Button {
                print("Speech test started")
            } label: {
                Text("말하기 테스트")
            }
        }
        .padding(20)
    }
}

#Preview {
    SpeechTestView(
        text:"잠시만 기다려 주세요."
    )
}
