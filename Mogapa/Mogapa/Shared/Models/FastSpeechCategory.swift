//
//  FastSpeechCategory.swift
//  Mogapa
//
//  Created by sun on 7/17/26.
//

import Foundation
import SwiftData

@Model
final class FastSpeechCategory {

    @Attribute(.unique)
    var id: UUID

    var name: String
    var sortOrder: Int

    @Relationship(deleteRule: .cascade, inverse: \FastSpeechPhrase.category)
    var phrases: [FastSpeechPhrase]

    init(
        id: UUID = UUID(),
        name: String,
        sortOrder: Int = 0,
        phrases: [FastSpeechPhrase] = []
    ) {
        self.id = id
        self.name = name
        self.sortOrder = sortOrder
        self.phrases = phrases
    }
}
