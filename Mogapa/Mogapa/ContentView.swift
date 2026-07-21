//
//  ContentView.swift
//  Mogapa
//
//  Created by sun on 7/13/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("포용용 화이팅")
                .typography(.bodyBold)
                .foregroundColor(.backgroundbgDefault)
        }
        .padding()
        
//    HomeMotionTestView() // 코어모션 테스트 하려면 주석을 지우세요
//        HomeView()
    }
}

#Preview {
    ContentView()
}
