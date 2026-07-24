//
//  PresentationView.swift
//  Mogapa
//
//  Created by sun on 7/21/26.
//

import SwiftUI
import UIKit

struct SpeechToken: Identifiable, Hashable {
    let id: Int
    let text: String
    let range: NSRange
}

struct PresentationView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: PresentationViewModel

    let orientation: UIInterfaceOrientationMask

    @AppStorage("settings.isBrightnessOn") private var isBrightnessOn: Bool = true
    @AppStorage("settings.manualBrightness") private var manualBrightness: Double = 50.0

    @State private var originalBrightness: CGFloat = UIScreen.main.brightness

    @State private var contentOpacity: Double = 0

    init(text: String, orientation: UIInterfaceOrientationMask) {
        _viewModel = State(initialValue: PresentationViewModel(text: text))
        self.orientation = orientation
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                background

                HStack(alignment: .top, spacing: 28) {
                    controls

                    textArea(
                        fontSize: viewModel.responsiveFontSize(
                            for: CGSize(width: proxy.size.height, height: proxy.size.width)
                        )
                    )
                }
                .padding(.horizontal, 80)
                .padding(.vertical, 40)
                .frame(width: proxy.size.height, height: proxy.size.width)
                .rotationEffect(targetRotationAngle)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
        .opacity(contentOpacity)
        .onAppear {
            originalBrightness = UIScreen.main.brightness

            if !isBrightnessOn {
                UIScreen.main.brightness = CGFloat(manualBrightness / 100)
            }

            withAnimation(.easeOut(duration: 0.25)) {
                contentOpacity = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                viewModel.handleMainPlaybackButton()
            }
        }
        .onDisappear {
            viewModel.stop()
            UIScreen.main.brightness = originalBrightness
        }
    }

    // MARK: - 회전 각도

    private var targetRotationAngle: Angle {
        switch orientation {
        case .landscapeLeft:
            return .degrees(-90)
        case .landscapeRight:
            return .degrees(90)
        default:
            return .degrees(0)
        }
    }

    // MARK: - 닫기 애니메이션

    private func closeWithAnimation() {
        viewModel.stop()

        withAnimation(.easeIn(duration: 0.2)) {
            contentOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            dismiss()
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
            BasicButton(
                systemImage: "arrow.down.right.and.arrow.up.left",
                shape: .circle,
                foregroundStyle: .white
            ) {
                closeWithAnimation()
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

    // MARK: - 텍스트 영역

    private func textArea(fontSize: CGFloat) -> some View {
        ReadAlongText(viewModel: viewModel, fontSize: fontSize)
    }
}
