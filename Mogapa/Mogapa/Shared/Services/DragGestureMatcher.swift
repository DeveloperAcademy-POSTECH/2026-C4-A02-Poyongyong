//
//  DragGestureMatcher.swift
//  Mogapa
//
//  Created by Sue on 7/22/26.
//  Based on code from Sun.
//

import Foundation

struct DragGestureMatch {
    let gesture: RegisteredDragGesture
    let score: Double
}

enum DragGestureMatcher {

    static func findBestMatch(
        drawnPoints: [CGPoint],
        gestures: [RegisteredDragGesture]
    ) -> DragGestureMatch? {
        let normalizedDrawn = DragGestureNormalizer.normalize(drawnPoints)

        guard !normalizedDrawn.isEmpty else { return nil }

        var bestMatch: DragGestureMatch?

        for gesture in gestures {
            guard gesture.points.count == normalizedDrawn.count else { continue }

            let score = averageDistance(normalizedDrawn, gesture.points)
            let match = DragGestureMatch(gesture: gesture, score: score)

            if bestMatch == nil || match.score < bestMatch!.score {
                bestMatch = match
            }
        }

        return bestMatch
    }

    private static func averageDistance(
        _ first: [DragPoint],
        _ second: [DragPoint]
    ) -> Double {
        guard first.count == second.count, !first.isEmpty else {
            return .greatestFiniteMagnitude
        }

        let total = zip(first, second).reduce(0.0) { partialResult, pair in
            let dx = pair.0.x - pair.1.x
            let dy = pair.0.y - pair.1.y

            return partialResult + sqrt(dx * dx + dy * dy)
        }

        return total / Double(first.count)
    }
}
