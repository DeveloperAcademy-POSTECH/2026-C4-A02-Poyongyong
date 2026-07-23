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

    var phrase: String
    var createdAt: Date
    var updatedAt: Date

    var points: [DragPoint]

    // 사용자가 지정한 리스트 순서
    var sortOrder: Int

    init(
        id: UUID = UUID(),
        phrase: String,
        points: [DragPoint] = [],
        createdAt: Date = .now,
        updatedAt: Date = .now,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.phrase = phrase
        self.points = points
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sortOrder = sortOrder
    }
}
