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
    @State private var contentHeight: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    
    init(text: String) {
        _viewModel = State(
            initialValue: PresentationViewModel(text: text)
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

    // MARK: - 배경

    private var background: some View {
        Color(.backgroundbgDefault)
            .ignoresSafeArea()
    }

    // MARK: - 왼쪽 버튼

    private var controls: some View {
        VStack(spacing: 20) {
            BasicButton(
                systemImage: "arrow.down.right.and.arrow.up.left",
                shape: .circle,
                foregroundStyle: .white
            ) {
                viewModel.stop()
                dismiss()
            }

            BasicButton(
                    systemImage: viewModel.mainPlaybackIcon,
                    shape: .circle,
                    foregroundStyle: .white
            ) {
                viewModel.handleMainPlaybackButton()
            }

            BasicButton(
                systemImage: "stop.fill",
                shape: .circle,
                foregroundStyle: .white
            ) {
                viewModel.stop()
            }
            .opacity(viewModel.isActive ? 1 : 0)
            .allowsHitTesting(viewModel.isActive)
        }
    }

    // MARK: - 텍스트 영역 (스크롤 + 자동 추적)

    private func textArea(fontSize: CGFloat) -> some View {
        ReadAlongText(viewModel: viewModel, fontSize: fontSize)
    }
    
    // MARK: - 스크롤 막대

    private func scrollTrack(containerHeight: CGFloat) -> some View {
        let visibleRatio = contentHeight > 0
            ? min(containerHeight / contentHeight, 1)
            : 1
        let thumbHeight = max(containerHeight * visibleRatio, 24)
        let maxScrollable = max(contentHeight - containerHeight, 1)
        let scrollProgress = min(max(-scrollOffset / maxScrollable, 0), 1)
        let thumbOffsetY = (containerHeight - thumbHeight) * scrollProgress

        return Capsule()
            .fill(.white.opacity(0.4))
            .frame(width: 4, height: thumbHeight)
            .offset(y: thumbOffsetY)
            .frame(height: containerHeight, alignment: .top)
            .opacity(contentHeight > containerHeight ? 1 : 0)
    }
    
    // MARK: - 단어 버튼

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
                    if viewModel.isCurrentlySpeaking(token) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.white.opacity(0.15))
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            viewModel.accessibilityText(for: token)
        )
    }

    // MARK: - 단어 색상

    private func tokenColor(for token: SpeechToken) -> Color {
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


#Preview {
    PresentationView(text: "백오십자를 맞추기 얼마나 힘든지 아십니까 여러분? 저는요 지금 상당히 재미있고 즐거워요 이런 것을 언제 또 해보겠습니까? 비록 클로드가 적은 코드가 오백줄 넘겠지만, 그래도 이정도 기여를 했다는 것이 얼마나 뿌듯합니까? 정말 흥미롭습니다. 이것만한게 없어요!! 제가 감")
}
