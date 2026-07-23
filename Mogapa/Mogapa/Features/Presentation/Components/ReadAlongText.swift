//
//  ReadAlongText.swift
//  Mogapa
//
//  Created by Sue on 7/22/26.
//

import SwiftUI

struct ReadAlongText: View {

    // MARK: - Properties

    let viewModel: PresentationViewModel
    let fontSize: CGFloat

    @State private var contentHeight: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0

    // MARK: - Body

    var body: some View {
        GeometryReader { containerGeometry in
            ScrollViewReader { proxy in
                ZStack(alignment: .trailing) {
                    scrollableTokens(proxy: proxy)

                    CustomScrollBar(
                        contentHeight: contentHeight,
                        scrollOffset: scrollOffset,
                        containerHeight: containerGeometry.size.height
                    )
                }
            }
        }
    }
}

// MARK: - Subviews

private extension ReadAlongText {

    func scrollableTokens(proxy: ScrollViewProxy) -> some View {
        ScrollView {
            WordWrapLayout(
                horizontalSpacing: 0,
                verticalSpacing: 8
            ) {
                ForEach(viewModel.tokens) { token in
                    tokenButton(token)
                        .id(token.id)
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.bottom, 20)
        }
        .padding(.trailing, 16)
        .scrollIndicators(.hidden)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentSize.height
        } action: { _, newValue in
            contentHeight = newValue
        }
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { _, newValue in
            scrollOffset = newValue
        }
        .onChange(of: viewModel.currentSpeakingTokenID) { _, tokenID in
            guard let tokenID else { return }

            withAnimation {
                proxy.scrollTo(tokenID, anchor: .center)
            }
        }
    }

    var heightAndOffsetReader: some View {
        GeometryReader { contentGeometry in
            Color.clear
                .preference(
                    key: ContentHeightKey.self,
                    value: contentGeometry.size.height
                )
                .preference(
                    key: ScrollOffsetKey.self,
                    value: contentGeometry.frame(in: .named("presentationScroll")).minY
                )
        }
    }

    func tokenButton(_ token: SpeechToken) -> some View {
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
                .foregroundStyle(tokenColor(for: token))
                .padding(.vertical, 2)
                .background {
                    if viewModel.isCurrentlySpeaking(token) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.white.opacity(0.15))
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(viewModel.accessibilityText(for: token))
    }

    func tokenColor(for token: SpeechToken) -> Color {
        switch viewModel.tokenDisplayState(for: token) {
        case .spoken:
            return .white
        case .speaking:
            return .yellow
        case .unspoken:
            return .white.opacity(0.32)
        }
    }
}

// MARK: - 스크롤 위치 추적

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct ContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
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

// TokenScrollArea.swift(ReadAlongText) 맨 아래

#Preview {
    ReadAlongText(
        viewModel: PresentationViewModel(),
        fontSize: 32
    )
    .background(.black)
}
