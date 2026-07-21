//
//  DrawingCanvas.swift
//  Mogapa
//
//  Created by sun on 7/20/26.
//

import SwiftUI

struct DrawingCanvas: View {
    @Binding var points: [CGPoint]
    @Binding var isFocused: Bool

    let lineWidth: CGFloat
    let onFinished: ([CGPoint]) -> Void

    init(
        points: Binding<[CGPoint]>,
        isFocused: Binding<Bool>,
        lineWidth: CGFloat = 10,
        onFinished: @escaping ([CGPoint]) -> Void
    ) {
        self._points = points
        self._isFocused = isFocused
        self.lineWidth = lineWidth
        self.onFinished = onFinished
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white

                if points.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "hand.draw")
                            .font(.system(size: 44))
                    }
                    .foregroundStyle(.secondary)
                }

                drawingPath
            }
            .frame(
                maxWidth: .infinity,
                minHeight: 318,
                maxHeight: 318
            )
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 40))
            .overlay {
                RoundedRectangle(cornerRadius: 40)
                    .stroke(
                        isFocused
                        ? Color(.backgroundbgDefault)
                        : .clear,
                        lineWidth: 2
                    )
                    .allowsHitTesting(false)
            }
            .contentShape(RoundedRectangle(cornerRadius: 40))
            .gesture(
                DragGesture(
                    minimumDistance: 0,
                    coordinateSpace: .local
                )
                .onChanged { value in
                    isFocused = true

                    let location = value.location

                    guard geometry.frame(in: .local).contains(location) else {
                        return
                    }

                    appendPoint(location)
                }
                .onEnded { _ in
                    onFinished(points)
                }
            )
        }
        .frame(height: 318)
    }

    private var drawingPath: some View {
        Path { path in
            guard let firstPoint = points.first else { return }

            path.move(to: firstPoint)

            for point in points.dropFirst() {
                path.addLine(to: point)
            }
        }
        .stroke(
            Color.primary,
            style: StrokeStyle(
                lineWidth: lineWidth,
                lineCap: .round,
                lineJoin: .round
            )
        )
    }

    private func appendPoint(_ newPoint: CGPoint) {
        guard let lastPoint = points.last else {
            points.append(newPoint)
            return
        }

        let distance = hypot(
            newPoint.x - lastPoint.x,
            newPoint.y - lastPoint.y
        )

        if distance >= 3 {
            points.append(newPoint)
        }
    }
}
