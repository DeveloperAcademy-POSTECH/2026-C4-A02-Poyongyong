//
//  DragGestureViewModel.swift
//  Mogapa
//
//  Created by sun on 7/24/26.
//

import CoreGraphics
import Foundation
import Observation

@MainActor
@Observable
final class DragGestureViewModel {

    private(set) var currentPoints: [CGPoint] = []
    private(set) var dragState: DragState = .none
    private(set) var recognizedTitle = "시작해 볼까요?"

    var isShowingEditView = false
    var isDimmed = false

    private let recognitionThreshold = 0.14
    private let speechManager = SpeechManager()

    private var isFinishing = false
    private var resetTask: Task<Void, Never>?
    private var dismissTask: Task<Void, Never>?

    func updateCurrentPoints(_ points: [CGPoint]) {
        currentPoints = points
    }

    func showEditView() {
        isShowingEditView = true
    }

    func appear() {
        isDimmed = true
    }

    func disappear() {
        resetTask?.cancel()
        dismissTask?.cancel()

        speechManager.stop()
    }

    func recognize(
        _ points: [CGPoint],
        registeredGestures: [RegisteredDragGesture],
        dismiss: @escaping () -> Void
    ) {
        guard !isFinishing else {
            return
        }

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
            let match = DragGestureMatcher.findBestMatch(
                drawnPoints: points,
                gestures: registeredGestures
            ),
            match.score <= recognitionThreshold
        else {
            presentResult(
                state: .failed,
                title: "인식하지 못했어요"
            )
            return
        }

        finish(
            phrase: match.gesture.phrase,
            dismiss: dismiss
        )
    }

    func dismissImmediately(
        dismiss: () -> Void
    ) {
        speechManager.stop()
        dismiss()
    }
}

// MARK: - Recognition Result

private extension DragGestureViewModel {

    func finish(
        phrase: String,
        dismiss: @escaping () -> Void
    ) {
        isFinishing = true

        presentResult(
            state: .succeeded,
            title: phrase
        )

        speechManager.play(phrase)

        dismissTask?.cancel()

        let delay = estimatedSpeechDuration(
            for: phrase
        )

        dismissTask = Task { [weak self] in
            try? await Task.sleep(
                nanoseconds: delay.nanoseconds
            )

            guard !Task.isCancelled else {
                return
            }

            self?.speechManager.stop()
            dismiss()
        }
    }

    func presentResult(
        state: DragState,
        title: String
    ) {
        resetTask?.cancel()

        dragState = state
        recognizedTitle = title
        currentPoints.removeAll()

        guard !isFinishing else {
            return
        }

        let delay = estimatedDisplayDuration(
            for: title
        )

        resetTask = Task { [weak self] in
            try? await Task.sleep(
                nanoseconds: delay.nanoseconds
            )

            guard !Task.isCancelled else {
                return
            }

            self?.resetResult()
        }
    }

    func resetResult() {
        dragState = .none
        recognizedTitle = "시작해 볼까요?"
    }
}

// MARK: - Duration

private extension DragGestureViewModel {

    func estimatedDisplayDuration(
        for text: String
    ) -> TimeInterval {
        let charactersPerSecond = 12.0
        let minimumDuration: TimeInterval = 1.0

        return max(
            Double(text.count) / charactersPerSecond,
            minimumDuration
        )
    }

    func estimatedSpeechDuration(
        for text: String
    ) -> TimeInterval {
        let charactersPerSecond = 4.5
        let minimumDuration: TimeInterval = 0.8
        let completionBuffer: TimeInterval = 0.2

        let estimatedDuration =
            Double(text.count) / charactersPerSecond

        return max(
            estimatedDuration,
            minimumDuration
        ) + completionBuffer
    }
}

// MARK: - TimeInterval

private extension TimeInterval {

    var nanoseconds: UInt64 {
        UInt64(max(self, 0) * 1_000_000_000)
    }
}
