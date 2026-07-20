//
//  AppPersistence.swift
//  Mogapa
//
//  Created by sun on 7/19/26.
//

import SwiftData

enum AppPersistence {

    static let shared: ModelContainer = {
        let schema = Schema([
            FastSpeechCategory.self,
            FastSpeechPhrase.self,
            RegisteredDragGesture.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("ModelContainer 생성 실패: \(error)")
        }
    }()
}
