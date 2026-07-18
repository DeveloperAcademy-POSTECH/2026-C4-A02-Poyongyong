//
//  DragPoint.swift
//  Mogapa
//
//  Created by sun on 7/17/26.
//

import Foundation

struct DragPoint: Codable, Hashable, Sendable {
    let x: Double
    let y: Double
    let sequence: Int
    let timestamp: TimeInterval
}
