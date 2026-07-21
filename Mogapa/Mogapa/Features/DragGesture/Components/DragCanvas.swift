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
        dragPath
            .stroke(
                .backgroundbgSpBubble,
                style: StrokeStyle(
                    lineWidth: 10,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .contentShape(Rectangle())
            .padding(.bottom, 66)
            .gesture(dragGesture)
            .overlay(canvasOutline)
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

    var canvasOutline: some View {
        RoundedRectangle(cornerRadius: 24)
            .stroke(Color("Strokedefault"), lineWidth: 1)
            .padding(.bottom, 66)
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            dragPoints.removeAll()
        }
    }
}

#Preview {
    @Previewable @State var points: [CGPoint] = []

    DragCanvas(dragPoints: $points) { finishedPoints in
        print("finished points: \(finishedPoints.count)")
    }
    .frame(height: 300)
    .background(.black.opacity(0.75))
}
