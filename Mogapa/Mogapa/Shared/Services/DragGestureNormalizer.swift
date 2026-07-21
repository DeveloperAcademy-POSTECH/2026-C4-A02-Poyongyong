//
//  DragGestureNormalizer.swift
//  Mogapa
//
//  Created by Sue on 7/22/26.
//  Based on code from Sun.
//

import CoreGraphics
import Foundation

enum DragGestureNormalizer {

    static let sampleCount = 48

    static func normalize(_ rawPoints: [CGPoint]) -> [DragPoint] {
        guard rawPoints.count >= 2 else { return [] }

        let resampled = resample(rawPoints, count: sampleCount)

        guard !resampled.isEmpty else { return [] }

        let minX = resampled.map(\.x).min() ?? 0
        let maxX = resampled.map(\.x).max() ?? 1
        let minY = resampled.map(\.y).min() ?? 0
        let maxY = resampled.map(\.y).max() ?? 1

        let width = max(maxX - minX, 1)
        let height = max(maxY - minY, 1)
        let scale = max(width, height)

        let scaled = resampled.map { point in
            CGPoint(
                x: (point.x - minX) / scale,
                y: (point.y - minY) / scale
            )
        }

        let centerX = scaled.map(\.x).reduce(0, +) / CGFloat(scaled.count)
        let centerY = scaled.map(\.y).reduce(0, +) / CGFloat(scaled.count)

        return scaled.enumerated().map { index, point in
            DragPoint(
                x: Double(point.x - centerX),
                y: Double(point.y - centerY),
                sequence: index,
                timestamp: 0
            )
        }
    }

    private static func resample(_ points: [CGPoint], count: Int) -> [CGPoint] {
        guard points.count >= 2, count >= 2 else { return points }

        let totalLength = pathLength(points)

        guard totalLength > 0 else { return [] }

        let interval = totalLength / CGFloat(count - 1)

        var result: [CGPoint] = [points[0]]
        var workingPoints = points
        var accumulatedDistance: CGFloat = 0
        var index = 1

        while index < workingPoints.count {
            let previous = workingPoints[index - 1]
            let current = workingPoints[index]
            let segmentDistance = distance(previous, current)

            if accumulatedDistance + segmentDistance >= interval {
                let ratio = (interval - accumulatedDistance) / max(segmentDistance, 0.0001)

                let newPoint = CGPoint(
                    x: previous.x + ratio * (current.x - previous.x),
                    y: previous.y + ratio * (current.y - previous.y)
                )

                result.append(newPoint)
                workingPoints.insert(newPoint, at: index)
                accumulatedDistance = 0
                index += 1
            } else {
                accumulatedDistance += segmentDistance
                index += 1
            }
        }

        while result.count < count, let last = points.last {
            result.append(last)
        }

        return Array(result.prefix(count))
    }

    private static func pathLength(_ points: [CGPoint]) -> CGFloat {
        guard points.count >= 2 else { return 0 }

        return zip(points, points.dropFirst())
            .map(distance)
            .reduce(0, +)
    }

    private static func distance(_ first: CGPoint, _ second: CGPoint) -> CGFloat {
        hypot(second.x - first.x, second.y - first.y)
    }
}
