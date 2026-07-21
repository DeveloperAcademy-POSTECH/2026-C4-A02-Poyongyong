//
//  MotionPresentationTestView.swift
//  Mogapa
//
//  Created by Purple on 7/21/26.
//

import SwiftUI

struct MotionPresentationTestView: View {

    @ObservedObject
    var motionManager: CoreMotionManager

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text(motionManager.pose.displayName)
                    .font(.system(size: 56, weight: .black))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                Text("테스트 프레젠테이션뷰")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.72))

                Text(String(format: "x %.2f  y %.2f  z %.2f", motionManager.gravityX, motionManager.gravityY, motionManager.gravityZ))
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.56))
            }
            .padding(28)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .rotationEffect(rotationAngle)
        }
        .onChange(of: motionManager.pose) { _, pose in
            guard !pose.isLandscape else { return }
            dismiss()
        }
    }

    private var rotationAngle: Angle {
        switch motionManager.pose {
        case .landscapeLeft:
            .degrees(90)
        case .landscapeRight:
            .degrees(-90)
        case .portrait, .flat, .unknown:
            .degrees(0)
        }
    }
}

#Preview {
    MotionPresentationTestView(motionManager: CoreMotionManager())
}
