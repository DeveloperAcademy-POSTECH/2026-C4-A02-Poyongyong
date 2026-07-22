//
//  FastSpeechPhrase.swift
//  Mogapa
//
//  Created by sun on 7/17/26.
//

import Foundation
import SwiftData

@Model
final class FastSpeechPhrase {

    @Attribute(.unique)
    var id: UUID

    var text: String
    var isPinned: Bool
    var sortOrder: Int
    var createdAt: Date

    var category: FastSpeechCategory?

    init(
        id: UUID = UUID(),
        text: String,
        isPinned: Bool = false,
        sortOrder: Int = 0,
        category: FastSpeechCategory? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.text = text
        self.isPinned = isPinned
        self.sortOrder = sortOrder
        self.category = category
        self.createdAt = createdAt
    }
}
