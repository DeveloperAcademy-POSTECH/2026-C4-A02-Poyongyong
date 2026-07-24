//
//  QuickSpeechBubbleRow.swift
//  Mogapa
//
//  Created by Purple on 7/21/26.
//

import SwiftUI

struct QuickSpeechBubbleRow<ID: Hashable>: View {

    // MARK: - Properties

    let id: ID
    let text: String
    let isSelected: Bool
    let isEditing: Bool
    let preservedLineLimit: Int?
    let onLineLimitMeasured: ((Int) -> Void)?

    @Binding var openedRowID: ID?

    let onTap: () -> Void
    let onSelectionToggle: () -> Void
    let onDelete: () -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var dragStartOffset: CGFloat?

    @State private var deleteOffset: CGFloat = 0
    @State private var isDeleting = false
    @State private var rowWidth: CGFloat = 0

    private let openOffset: CGFloat = 62
    private let openThreshold: CGFloat = 31

    private let checkboxSize: CGFloat = 18
    private let checkboxSpacing: CGFloat = 12

    private let deleteAnimationDuration: TimeInterval = 0.24

    // MARK: - Initializer

    init(
        id: ID,
        text: String,
        isSelected: Bool = false,
        isEditing: Bool = false,
        preservedLineLimit: Int? = nil,
        onLineLimitMeasured: ((Int) -> Void)? = nil,
        openedRowID: Binding<ID?>,
        onTap: @escaping () -> Void,
        onSelectionToggle: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.id = id
        self.text = text
        self.isSelected = isSelected
        self.isEditing = isEditing
        self.preservedLineLimit = preservedLineLimit
        self.onLineLimitMeasured = onLineLimitMeasured
        self._openedRowID = openedRowID
        self.onTap = onTap
        self.onSelectionToggle = onSelectionToggle
        self.onDelete = onDelete
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            actionButtons

            rowContent
                .offset(x: displayedOffset + deleteOffset)
                .overlay {
                    if !isEditing && !isDeleting {
                        HorizontalSwipeRecognizer(
                            onChanged: handleHorizontalSwipeChanged,
                            onEnded: handleHorizontalSwipeEnded,
                            onCancelled: handleHorizontalSwipeCancelled
                        )
                    }
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 59)
        .fixedSize(horizontal: false, vertical: true)
        .clipped()
        .background {
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        rowWidth = proxy.size.width
                    }
                    .onChange(of: proxy.size.width) { _, newValue in
                        rowWidth = newValue
                    }
            }
        }
        .onChange(of: openedRowID) { _, newValue in
            guard newValue != id else {
                return
            }

            guard dragOffset != 0 else {
                return
            }

            close()
        }
        .onChange(of: isEditing) { _, newValue in
            guard newValue else {
                return
            }

            close()
        }
    }
}

// MARK: - Subviews

private extension QuickSpeechBubbleRow {
    var displayedOffset: CGFloat {
        isEditing ? 0 : dragOffset
    }

    var actionButtons: some View {
        HStack {
            Spacer()

            QuickSpeechSwipeActionButton(.delete) {
                startDeleteAnimation()
            }
            .opacity(displayedOffset < 0 ? 1 : 0)
            .allowsHitTesting(displayedOffset < 0)
        }
        .frame(maxWidth: .infinity)
    }

    var rowContent: some View {
        HStack(spacing: checkboxSpacing) {
            if isEditing {
                checkbox
                    .onTapGesture {
                        onSelectionToggle()
                    }
            }

            QuickSpeechBubble(
                text: text,
                isEditing: isEditing,
                preservedLineLimit: preservedLineLimit,
                onLineLimitMeasured: onLineLimitMeasured,
                action: nil
            )
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            if isEditing {
                onSelectionToggle()
            } else if isInteractiveBubble {
                onTap()
            }
        }
        .accessibilityAddTraits(
            isEditing || isInteractiveBubble
            ? .isButton
            : []
        )
    }

    var checkbox: some View {
        ZStack {
            Circle()
                .fill(
                    isSelected
                    ? .accentsBlue
                    : .backgroundbgCanvas
                )
                .overlay {
                    Circle()
                        .stroke(
                            isSelected
                            ? .accentsBlue
                            : .strokedefault,
                            lineWidth: 1
                        )
                }

            if isSelected {
                Image(systemName: "checkmark")
                    .font(
                        .system(
                            size: 10,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(.iconinverse)
            }
        }
        .frame(
            width: checkboxSize,
            height: checkboxSize
        )
        .contentShape(Circle())
        .accessibilityAddTraits(.isButton)
    }

    var isInteractiveBubble: Bool {
        !isEditing &&
        dragOffset == 0 &&
        openedRowID != id
    }
}

// MARK: - Swipe Handling

private extension QuickSpeechBubbleRow {
    func handleHorizontalSwipeChanged(
        translation: CGFloat
    ) {
        guard !isEditing, !isDeleting else {
            return
        }

        let startOffset: CGFloat

        if let dragStartOffset {
            startOffset = dragStartOffset
        } else {
            startOffset = dragOffset
            self.dragStartOffset = dragOffset
        }

        let proposedOffset =
            startOffset + translation

        dragOffset = clampedOffset(proposedOffset)
    }

    func handleHorizontalSwipeEnded(
        translation: CGFloat,
        predictedTranslation: CGFloat
    ) {
        guard !isEditing, !isDeleting else {
            resetDragState()
            return
        }

        let startOffset =
            dragStartOffset ?? dragOffset

        let predictedOffset =
            startOffset + predictedTranslation

        dragStartOffset = nil

        withAnimation(.snappy) {
            if predictedOffset < -openThreshold {
                openedRowID = id
                dragOffset = -openOffset
            } else {
                if openedRowID == id {
                    openedRowID = nil
                }

                dragOffset = 0
            }
        }
    }

    func handleHorizontalSwipeCancelled() {
        guard !isDeleting else {
            return
        }

        dragStartOffset = nil

        withAnimation(.snappy) {
            if openedRowID == id {
                dragOffset = -openOffset
            } else {
                dragOffset = 0
            }
        }
    }

    private func clampedOffset(
        _ offset: CGFloat
    ) -> CGFloat {
        min(
            0,
            max(-openOffset, offset)
        )
    }

    func resetDragState() {
        dragStartOffset = nil
    }
}

// MARK: - Actions

private extension QuickSpeechBubbleRow {
    func close() {
        withAnimation(.snappy) {
            if openedRowID == id {
                openedRowID = nil
            }

            dragOffset = 0
            dragStartOffset = nil
        }
    }

    func startDeleteAnimation() {
        guard !isDeleting else {
            return
        }

        isDeleting = true

        withAnimation(
            .easeInOut(
                duration: deleteAnimationDuration
            )
        ) {
            deleteOffset =
                -(rowWidth + openOffset)
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() +
                deleteAnimationDuration
        ) {
            onDelete()
            close()
        }
    }
}

// MARK: - Horizontal Swipe Recognizer

private struct HorizontalSwipeRecognizer: UIViewRepresentable {
    let onChanged: (_ translation: CGFloat) -> Void

    let onEnded: (
        _ translation: CGFloat,
        _ predictedTranslation: CGFloat
    ) -> Void

    let onCancelled: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onChanged: onChanged,
            onEnded: onEnded,
            onCancelled: onCancelled
        )
    }

    func makeUIView(
        context: Context
    ) -> UIView {
        let view = UIView(frame: .zero)

        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true

        let panGesture =
            UIPanGestureRecognizer(
                target: context.coordinator,
                action: #selector(
                    Coordinator.handlePanGesture(_:)
                )
            )

        panGesture.delegate =
            context.coordinator

        panGesture.cancelsTouchesInView = false
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        panGesture.maximumNumberOfTouches = 1

        view.addGestureRecognizer(panGesture)

        context.coordinator.panGesture =
            panGesture

        return view
    }

    func updateUIView(
        _ uiView: UIView,
        context: Context
    ) {
        context.coordinator.onChanged =
            onChanged

        context.coordinator.onEnded =
            onEnded

        context.coordinator.onCancelled =
            onCancelled
    }
}

// MARK: - Horizontal Swipe Coordinator

private extension HorizontalSwipeRecognizer {
    final class Coordinator:
        NSObject,
        UIGestureRecognizerDelegate
    {
        var onChanged:
            (_ translation: CGFloat) -> Void

        var onEnded: (
            _ translation: CGFloat,
            _ predictedTranslation: CGFloat
        ) -> Void

        var onCancelled: () -> Void

        weak var panGesture:
            UIPanGestureRecognizer?

        init(
            onChanged: @escaping (
                _ translation: CGFloat
            ) -> Void,
            onEnded: @escaping (
                _ translation: CGFloat,
                _ predictedTranslation: CGFloat
            ) -> Void,
            onCancelled: @escaping () -> Void
        ) {
            self.onChanged = onChanged
            self.onEnded = onEnded
            self.onCancelled = onCancelled
        }

        @objc
        func handlePanGesture(
            _ gesture:
                UIPanGestureRecognizer
        ) {
            let translation =
                gesture.translation(
                    in: gesture.view
                )

            switch gesture.state {
            case .began, .changed:
                onChanged(translation.x)

            case .ended:
                let velocity =
                    gesture.velocity(
                        in: gesture.view
                    )

                let predictionDuration:
                    CGFloat = 0.2

                let predictedTranslation =
                    translation.x +
                    velocity.x *
                    predictionDuration

                onEnded(
                    translation.x,
                    predictedTranslation
                )

            case .cancelled, .failed:
                onCancelled()

            default:
                break
            }
        }

        func gestureRecognizerShouldBegin(
            _ gestureRecognizer:
                UIGestureRecognizer
        ) -> Bool {
            guard let panGesture =
                    gestureRecognizer
                    as? UIPanGestureRecognizer
            else {
                return false
            }

            let velocity =
                panGesture.velocity(
                    in: panGesture.view
                )

            let horizontalVelocity =
                abs(velocity.x)

            let verticalVelocity =
                abs(velocity.y)

            guard horizontalVelocity >
                    verticalVelocity else {
                return false
            }

            return horizontalVelocity > 20
        }

        func gestureRecognizer(
            _ gestureRecognizer:
                UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith
            otherGestureRecognizer:
                UIGestureRecognizer
        ) -> Bool {
            false
        }
    }
}

// MARK: - Preview

private struct QuickSpeechBubbleRowPreviewPhrase:
    Identifiable
{
    let id = UUID()
    let text: String
}

private struct QuickSpeechBubbleRowPreview: View {
    @State private var openedRowID: UUID?
    @State private var isEditing = false
    @State private var selectedIDs: Set<UUID> = []
    @State private var lineLimits: [UUID: Int] = [:]

    @State private var phrases = [
        QuickSpeechBubbleRowPreviewPhrase(
            text: "텍스트 입력"
        ),
        QuickSpeechBubbleRowPreviewPhrase(
            text: """
            얼마나 길게 써지나 함 봐볼까요. 근데 이거 길게 쓰면 밑으로 내려가네요. 딱 맞춰서 이어지는지!!!
            """
        ),
        QuickSpeechBubbleRowPreviewPhrase(
            text: "텍스트 입력"
        )
    ]

    var body: some View {
        VStack(spacing: 10) {
            Button(
                isEditing ? "완료" : "편집"
            ) {
                withAnimation(.snappy) {
                    isEditing.toggle()
                }
            }

            ForEach(phrases) { phrase in
                QuickSpeechBubbleRow(
                    id: phrase.id,
                    text: phrase.text,
                    isSelected:
                        selectedIDs.contains(
                            phrase.id
                        ),
                    isEditing: isEditing,
                    preservedLineLimit:
                        lineLimits[phrase.id],
                    onLineLimitMeasured: {
                        lineLimits[phrase.id] = $0
                    },
                    openedRowID: $openedRowID,
                    onTap: {},
                    onSelectionToggle: {
                        toggleSelection(
                            for: phrase.id
                        )
                    },
                    onDelete: {
                        withAnimation(.snappy) {
                            phrases.removeAll {
                                $0.id == phrase.id
                            }
                        }
                    }
                )
            }
        }
        .padding(.horizontal, 20)
    }

    private func toggleSelection(
        for id: UUID
    ) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

}

#Preview("QuickSpeechBubbleRow") {
    QuickSpeechBubbleRowPreview()
        .environment(
            \.locale,
            Locale(identifier: "ko")
        )
}
