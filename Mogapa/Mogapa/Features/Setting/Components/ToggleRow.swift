//
//  ToggleSection.swift
//  Mogapa
//
//  Created by 김지원 on 7/21/26.
//
// 프레젠테이션뷰 밝기 조절 & 가로 전환

import SwiftUI

struct ToggleRow: View {
    let label: String // ex. 자동 밝기, 가로 전환
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Text(label)
                .typography(.bodyMedium)
                .foregroundStyle(Color.textsecondary)
        }
        .frame(height: 52)
        .padding(.horizontal, 24)
    }
}

#Preview {
    ToggleRow(label: "자동 밝기", isOn: .constant(false))
}
