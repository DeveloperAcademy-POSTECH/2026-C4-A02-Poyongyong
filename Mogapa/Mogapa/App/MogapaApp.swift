//
//  MogapaApp.swift
//  Mogapa
//
//  Created by sun on 7/13/26.
//

import SwiftUI
import SwiftData

//@main
//struct MogapaApp: App {
//    var body: some Scene {
//        WindowGroup {
//            //ContentView()
//            HomeView()
//        }
//        .modelContainer(AppPersistence.shared)
//    }
//}

@main
struct MogapaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(AppPersistence.shared)
    }
}
