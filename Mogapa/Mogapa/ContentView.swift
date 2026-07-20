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
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
