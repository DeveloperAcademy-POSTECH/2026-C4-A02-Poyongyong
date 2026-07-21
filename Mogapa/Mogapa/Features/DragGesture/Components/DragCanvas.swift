//
//  DragCanvas.swift
//  Mogapa
//
//  Created by Sue on 7/21/26.
//

import SwiftUI

struct DragCanvas: View {

    @Binding var dragPoints: [CGPoint]
    @State private var isDragging = false

    let onFinished: ([CGPoint]) -> Void

    var body: some View {
        ZStack(alignment: .center) {
            dragPath
                .stroke(
                    Color.blue,
                    style: StrokeStyle(
                        lineWidth: 10,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
        }
        .contentShape(Rectangle())
        .gesture(dragGesture)
    }
}

private extension DragCanvas {

    var dragPath: Path {
        Path { path in
            guard let firstPoint = dragPoints.first else { return }

            path.move(to: firstPoint)

            for dragPoint in dragPoints.dropFirst() {
                path.addLine(to: dragPoint)
            }
        }
    }
}

private extension DragCanvas {

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                appendDragPoint(value.location)
            }
            .onEnded { _ in
                finishDragGesture()
            }
    }

    func appendDragPoint(_ point: CGPoint) {
        isDragging = true
        dragPoints.append(point)
    }

    func finishDragGesture() {
        isDragging = false
        onFinished(dragPoints)
    }
}

#Preview {
    DragCanvasPreview()
}

private struct DragCanvasPreview: View {
    @State private var dragPoints: [CGPoint] = []

    var body: some View {
        DragCanvas(
            dragPoints: $dragPoints,
            onFinished: { points in
                print(points)
            }
        )
        .frame(width: 300, height: 300)
        .border(.gray)
    }
}
