//
//  DragGestureView.swift
//  Mogapa
//
//  Created by Sue on 7/21/26.
//

import SwiftUI

struct DragGestureView: View {

    @State private var currentPoints: [CGPoint] = []
    @State private var dragState: DragState = .none
    @State private var recognizedTitle = "시작해 볼까요?"
    @State private var isDimmed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DragHeader()

            DragIndicator(
                title: recognizedTitle,
                state: dragState
            )

            DragCanvas(dragPoints: $currentPoints) { finishedPoints in
                recognize(finishedPoints)
            }
        }
        .padding()
        .background(dimBackground)
        .overlay(alignment: .bottomTrailing) { homeButton }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.25)) {
                isDimmed = true
            }
        }
    }
}

private extension DragGestureView {

    var dimBackground: some View {
        Color.black
            .opacity(isDimmed ? 0.6 : 0)
            .ignoresSafeArea()
    }

    var homeButton: some View {
        BasicButton(
            systemImage: "arrow.down.right.and.arrow.up.left",
            shape: .circle,
            foregroundStyle: .white
        ) {
            // TODO: 홈 화면 복귀 액션 연결
        }
        .padding(20)
    }
}

private extension DragGestureView {

    func recognize(_ points: [CGPoint]) {
        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                dragState = .none
                recognizedTitle = "시작해 볼까요?"
            }
        }

        guard points.count >= 8 else {
            dragState = .failed
            recognizedTitle = "조금 더 길게 그려주세요"
            return
        }

        // TODO: 실제 매칭 로직(DragGestureNormalizer + DragGestureMatcher)으로 교체
        let isMatched = Bool.random()

        if isMatched {
            dragState = .succeeded
            recognizedTitle = "하이하이"
        } else {
            dragState = .failed
            recognizedTitle = "인식하지 못했어요"
        }
    }
}

#Preview {
    DragGestureView()
}
