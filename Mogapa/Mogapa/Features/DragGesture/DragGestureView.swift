//
//  DragGestureView.swift
//  Mogapa
//
//  Created by Sue on 7/21/26.
//

import SwiftUI
import SwiftData

struct DragGestureView: View {
    
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \RegisteredDragGesture.createdAt)
    private var registeredGestures: [RegisteredDragGesture]

    @State private var currentPoints: [CGPoint] = []
    @State private var dragState: DragState = .none
    @State private var recognizedTitle = "시작해 볼까요?"
    @State private var isShowingEditView = false
    @State private var isDimmed = false

    private let recognitionThreshold = 0.14

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 32
        ) {
            DragHeader {
                isShowingEditView = true
            }

            VStack(
                alignment: .leading
            ) {
                DragIndicator(
                    title: recognizedTitle,
                    state: dragState
                )

                DragCanvas(
                    dragPoints: $currentPoints
                ) { finishedPoints in
                    recognize(
                        finishedPoints
                    )
                }
            }
        }
        .padding(
            [.bottom, .top],
            32
        )
        .padding(
            [.leading, .trailing],
            20
        )
        .background(
            dimBackground
        )
        .overlay(
            alignment: .bottomTrailing
        ) {
            homeButton
        }
        .navigationDestination(
            isPresented: $isShowingEditView
        ) {
            DragGestureEditView(viewModel: DragGestureEditViewModel())
        }
        .onAppear {
            withAnimation(
                .easeInOut(
                    duration: 0.25
                )
            ) {
                isDimmed = true
            }
        }
    }
}

private extension DragGestureView {

    var dimBackground: some View {
        Color.black
            .opacity(
                isDimmed ? 0.6 : 0
            )
            .ignoresSafeArea()
    }

    var homeButton: some View {
        BasicButton(
            systemImage:
                "arrow.down.right.and.arrow.up.left",
            shape: .circle,
            foregroundStyle: .white
        ) {
            dismiss()
        }
        .padding(
            20
        )
    }
}

private extension DragGestureView {

    func recognize(
        _ points: [CGPoint]
    ) {
        guard points.count >= 8 else {
            presentResult(
                state: .failed,
                title: "조금 더 길게 그려주세요"
            )
            return
        }

        guard !registeredGestures.isEmpty else {
            presentResult(
                state: .failed,
                title: "먼저 패턴을 등록해 주세요"
            )
            return
        }

        guard
            let match =
                DragGestureMatcher
                    .findBestMatch(
                        drawnPoints: points,
                        gestures:
                            registeredGestures
                    ),
            match.score <=
                recognitionThreshold
        else {
            presentResult(
                state: .failed,
                title: "인식하지 못했어요"
            )
            return
        }

        presentResult(
            state: .succeeded,
            title:
                match.gesture.phrase
        )
    }

    func presentResult(
        state: DragState,
        title: String
    ) {
        dragState = state
        recognizedTitle = title

        let resetDelay =
            estimatedDisplayDuration(
                for: title
            )

        DispatchQueue.main.asyncAfter(
            deadline:
                .now() + resetDelay
        ) {
            dragState = .none
            recognizedTitle =
                "시작해 볼까요?"
        }
    }

    func estimatedDisplayDuration(
        for text: String
    ) -> TimeInterval {
        let charactersPerSecond =
            12.0

        let minimumDuration:
            TimeInterval = 1.0

        return max(
            Double(text.count) /
                charactersPerSecond,
            minimumDuration
        )
    }
}

#Preview {
    NavigationStack {
        DragGestureView()
    }
}
