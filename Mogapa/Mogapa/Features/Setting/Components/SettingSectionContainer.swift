//
//  SettingSectionContainer.swift
//  Mogapa
//
//  Created by 김지원 on 7/21/26.
//

import SwiftUI

struct SettingSectionContainer<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .typography(.bodySemiBold)
                .foregroundStyle(Color("Texttertiary"))
                .padding(.leading, 32)
                .padding(.bottom, 6)
            
            content
                .background(Color("Backgroundbg-canvas"))
                .clipShape(RoundedRectangle(cornerRadius: 26))
                .padding(.horizontal, 20)
        }
    }
}

#Preview {
    SettingSectionContainer(title: "프레젠테이션뷰 밝기 조절") {
        ToggleRow(label: "자동 밝기", isOn: .constant(false))
    }
    .background(Color("Backgroundbg-disabled"))
}
