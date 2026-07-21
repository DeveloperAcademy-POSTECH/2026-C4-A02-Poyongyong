//
//  SettingView.swift
//  Mogapa
//
//  Created by 김지원 on 7/21/26.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        VStack {
            // 앱 공용 헤더 컴포넌트 재사용
            MogapaNavigationHeader(
                title: "설정",
                rightTitle: "재설정",
                onLeftTap: {},
                onRightTap: {}
            )
            .environment(\.locale, Locale(identifier: "ko"))
        }
    }
}

#Preview {
    SettingView()
}
