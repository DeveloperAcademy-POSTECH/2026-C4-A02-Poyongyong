//
//  SwipeBackModifier.swift
//  Mogapa
//
//  Created by sun on 7/24/26.
//

import SwiftUI
import UIKit

private struct SwipeBackController: UIViewControllerRepresentable {
    let isEnabled: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        Controller(isEnabled: isEnabled)
    }

    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) {
        guard let controller = uiViewController as? Controller else {
            return
        }

        controller.isEnabled = isEnabled
        controller.updateSwipeBackState()
    }

    private final class Controller: UIViewController {
        var isEnabled: Bool

        init(isEnabled: Bool) {
            self.isEnabled = isEnabled

            super.init(
                nibName: nil,
                bundle: nil
            )
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)

            updateSwipeBackState()
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)

            // 다른 화면에 이전 설정이 남지 않도록 원상 복구
            navigationController?
                .interactivePopGestureRecognizer?
                .isEnabled = true
        }

        func updateSwipeBackState() {
            guard let navigationController else {
                return
            }

            navigationController
                .interactivePopGestureRecognizer?
                .isEnabled = isEnabled

            if isEnabled {
                navigationController
                    .interactivePopGestureRecognizer?
                    .delegate = nil
            }
        }
    }
}

extension View {
    func swipeBackEnabled(_ isEnabled: Bool) -> some View {
        background {
            SwipeBackController(
                isEnabled: isEnabled
            )
            .frame(
                width: 0,
                height: 0
            )
        }
    }
}
