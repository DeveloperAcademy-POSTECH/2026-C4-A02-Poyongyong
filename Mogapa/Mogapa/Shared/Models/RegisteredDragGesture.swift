//
//  RegisteredDragGesture.swift
//  Mogapa
//
//  Created by sun on 7/17/26.
//

import Foundation
import SwiftData

@Model
final class RegisteredDragGesture {

    @Attribute(.unique)
    var id: UUID

    var name: String
    var phrase: String
    var createdAt: Date
    var updatedAt: Date

    var points: [DragPoint]

    init(
        id: UUID = UUID(),
        name: String,
        phrase: String,
        points: [DragPoint] = [],
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.phrase = phrase
        self.points = points
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
