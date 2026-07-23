//
//  DragPoint.swift
//  Mogapa
//
//  Created by sun on 7/17/26.
//

import Foundation

struct DragPoint: Codable, Hashable {
    var x: Double
    var y: Double
    var sequence: Int
    var timestamp: Double

    init(
        x: Double,
        y: Double,
        sequence: Int,
        timestamp: Double
    ) {
        self.x = x
        self.y = y
        self.sequence = sequence
        self.timestamp = timestamp
    }
}
