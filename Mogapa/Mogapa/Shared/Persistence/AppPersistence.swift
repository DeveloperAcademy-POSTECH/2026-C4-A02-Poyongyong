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
            let container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            FastSpeechDefaultTemplate.seedIfNeeded(
                in: container
            )
            return container
        } catch {
            fatalError("ModelContainer 생성 실패: \(error)")
        }
    }()
}
