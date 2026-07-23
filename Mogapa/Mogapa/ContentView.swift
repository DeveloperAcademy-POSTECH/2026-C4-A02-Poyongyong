//
//  ContentView.swift
//  Mogapa
//
//  Created by sun on 7/13/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView()
        
//    HomeMotionTestView() // 코어모션 테스트 하려면 주석을 지우세요

    }
}

#Preview {
    ContentView()
        .environment(\.locale, Locale(identifier: "ko"))
}
