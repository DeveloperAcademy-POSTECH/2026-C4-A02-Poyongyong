//
//  DragGestureView.swift
//  Mogapa
//
//  Created by Sue on 7/21/26.
//

import SwiftUI
import SwiftData

struct DragGestureView: View {

    @Query(sort: \RegisteredDragGesture.createdAt)
    private var registeredGestures: [RegisteredDragGesture]

    @State private var currentPoints: [CGPoint] = []
    @State private var dragState: DragState = .none
    @State private var recognizedTitle = "시작해 볼까요?"
    @State private var isShowingEditModal = false
    @State private var isDimmed = false

    private let recognitionThreshold = 0.14

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DragHeader {
                isShowingEditModal = true
            }

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
        // TODO: 추후 NavigationView로 연결될 예정 — 그때는 .sheet 대신
        // .navigationDestination(isPresented:) 방식으로 교체 필요
        .sheet(isPresented: $isShowingEditModal) {
            GestureModalContent(title: "제스처 편집")
        }
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
        guard points.count >= 8 else {
            presentResult(state: .failed, title: "조금 더 길게 그려주세요")
            return
        }

        guard !registeredGestures.isEmpty else {
            presentResult(state: .failed, title: "먼저 패턴을 등록해 주세요")
            return
        }

        guard
            let match = DragGestureMatcher.findBestMatch(
                drawnPoints: points,
                gestures: registeredGestures
            ),
            match.score <= recognitionThreshold
        else {
            presentResult(state: .failed, title: "인식하지 못했어요")
            return
        }

        presentResult(state: .succeeded, title: match.gesture.phrase)

        // TODO: 주니 SpeechManager 나오면 여기서 speak(match.gesture.phrase) 호출하고,
        // 아래 estimatedDisplayDuration 대신 실제 재생 완료 시점에 맞춰 리셋하도록 교체
    }

    func presentResult(state: DragState, title: String) {
        dragState = state
        recognizedTitle = title

        let resetDelay = estimatedDisplayDuration(for: title)

        DispatchQueue.main.asyncAfter(deadline: .now() + resetDelay) {
            dragState = .none
            recognizedTitle = "시작해 볼까요?"
        }
    }

    func estimatedDisplayDuration(for text: String) -> TimeInterval {
        let charactersPerSecond = 12.0
        let minimumDuration: TimeInterval = 1.0

        return max(Double(text.count) / charactersPerSecond, minimumDuration)
    }
}

#Preview {
    DragGestureView()
}
