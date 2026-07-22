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

    init(text: String, orientation: UIInterfaceOrientationMask) {
        _viewModel = State(
            initialValue: PresentationViewModel(text: text)
        )
        self.orientation = orientation
    }

    // MARK: - Body

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
        .onAppear {
            AppDelegate.lock(to: orientation)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                viewModel.handleMainPlaybackButton()
            }
        }
        .onDisappear {
            viewModel.stop()
            AppDelegate.lock(to: .portrait)
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

    // MARK: - 텍스트 영역

    private func textArea(fontSize: CGFloat) -> some View {
        ReadAlongText(viewModel: viewModel, fontSize: fontSize)
    }
}

// MARK: - 화면 방향 강제

private extension PresentationView {
    func lockOrientation(to mask: UIInterfaceOrientationMask) {
        AppDelegate.orientationLock = mask

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }

        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: mask))
        windowScene.windows.first?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
    }
}
