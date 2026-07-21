//
//  MogapaApp.swift
//  Mogapa
//
//  Created by sun on 7/13/26.
//

import SwiftUI
import SwiftData

@main
struct MogapaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(AppPersistence.shared)
    }
}
