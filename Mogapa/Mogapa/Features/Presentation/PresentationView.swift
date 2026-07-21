//
//  PresentationView.swift
//  Mogapa
//
//  Created by sun on 7/21/26.
//

import SwiftUI

struct SpeechToken: Identifiable, Hashable {
    let id: Int
    let text: String
    let range: NSRange
}

struct PresentationView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: PresentationViewModel

    init() {
        _viewModel = State(
            initialValue: PresentationViewModel()
        )
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                background

                HStack(
                    alignment: .top,
                    spacing: 28
                ) {
                    controls

                    textArea(
                        fontSize:
                            viewModel.responsiveFontSize(
                                for: geometry.size
                            )
                    )
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 28)
            }
        }
        .onDisappear {
            viewModel.stop()
        }
    }

    // MARK: - 배경

    private var background: some View {
        Color(.backgroundbgDefault)
            .ignoresSafeArea()
    }

    // MARK: - 왼쪽 버튼

    private var controls: some View {
        VStack(spacing: 20) {
            CircleButton(
                systemName: "arrow.up.left.and.arrow.down.right"
            ) {
                viewModel.stop()
                dismiss()
            }

            CircleButton(
                systemName:
                    viewModel.mainPlaybackIcon
            ) {
                viewModel.handleMainPlaybackButton()
            }

            CircleButton(
                systemName: "stop.fill"
            ) {
                viewModel.stop()
            }
            .opacity(
                viewModel.isActive ? 1 : 0
            )
            .allowsHitTesting(
                viewModel.isActive
            )
        }
    }

    // MARK: - 텍스트 영역

    private func textArea(
        fontSize: CGFloat
    ) -> some View {
        ScrollView {
            WordWrapLayout(
                horizontalSpacing: 0,
                verticalSpacing: 8
            ) {
                ForEach(viewModel.tokens) { token in
                    tokenButton(
                        token,
                        fontSize: fontSize
                    )
                }
            }
            .frame(
                maxWidth: .infinity,
                alignment: .topLeading
            )
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - 단어 버튼

    private func tokenButton(
        _ token: SpeechToken,
        fontSize: CGFloat
    ) -> some View {
        Button {
            viewModel.play(from: token)
        } label: {
            Text(token.text)
                .font(
                    .system(
                        size: fontSize,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    tokenColor(for: token)
                )
                .padding(.vertical, 2)
                .background {
                    if viewModel.isCurrentlySpeaking(
                        token
                    ) {
                        RoundedRectangle(
                            cornerRadius: 6
                        )
                        .fill(
                            .white.opacity(0.15)
                        )
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            viewModel.accessibilityText(
                for: token
            )
        )
    }

    // MARK: - 단어 색상

    private func tokenColor(
        for token: SpeechToken
    ) -> Color {
        switch viewModel.tokenDisplayState(
            for: token
        ) {
        case .spoken:
            return .white

        case .speaking:
            return .yellow

        case .unspoken:
            return .white.opacity(0.32)
        }
    }
}

// MARK: - 원형 버튼

private struct CircleButton: View {

    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(
                    .system(
                        size: 18,
                        weight: .bold
                    )
                )
                .foregroundStyle(.black)
                .frame(
                    width: 44,
                    height: 44
                )
                .background(
                    .white.opacity(0.58)
                )
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 자동 줄바꿈 Layout

private struct WordWrapLayout: Layout {

    var horizontalSpacing: CGFloat = 0
    var verticalSpacing: CGFloat = 8

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let availableWidth =
            proposal.width ?? .infinity

        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var currentLineHeight: CGFloat = 0
        var contentWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(
                .unspecified
            )

            let exceedsWidth =
                currentX > 0
                && currentX + size.width
                    > availableWidth

            if exceedsWidth {
                currentX = 0
                currentY +=
                    currentLineHeight
                    + verticalSpacing
                currentLineHeight = 0
            }

            currentX +=
                size.width
                + horizontalSpacing

            currentLineHeight = max(
                currentLineHeight,
                size.height
            )

            contentWidth = max(
                contentWidth,
                currentX
            )
        }

        let finalWidth =
            availableWidth.isFinite
            ? availableWidth
            : contentWidth

        return CGSize(
            width: finalWidth,
            height:
                currentY
                + currentLineHeight
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var currentLineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(
                .unspecified
            )

            let exceedsWidth =
                currentX > bounds.minX
                && currentX + size.width
                    > bounds.maxX

            if exceedsWidth {
                currentX = bounds.minX
                currentY +=
                    currentLineHeight
                    + verticalSpacing
                currentLineHeight = 0
            }

            subview.place(
                at: CGPoint(
                    x: currentX,
                    y: currentY
                ),
                anchor: .topLeading,
                proposal: ProposedViewSize(
                    width: size.width,
                    height: size.height
                )
            )

            currentX +=
                size.width
                + horizontalSpacing

            currentLineHeight = max(
                currentLineHeight,
                size.height
            )
        }
    }
}
