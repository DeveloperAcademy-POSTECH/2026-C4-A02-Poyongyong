//
//  HomeMotionTestView.swift
//  Mogapa
//
//  Created by Purple on 7/21/26.
//

import SwiftUI

struct HomeMotionTestView: View {

    @StateObject
    private var motionManager = CoreMotionManager()

    @State
    private var isPresentationPresented = false

    @State
    private var isGesturePresented = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                VStack(spacing: 10) {
                    Text("CoreMotion Test")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.primary)

                    Text("홈테스트뷰")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 16) {
                    statusRow(title: "현재 자세", value: motionManager.pose.displayName)
                    statusRow(title: "Roll", value: String(format: "%.1f도", motionManager.rollDegrees))
                    statusRow(title: "Pitch", value: String(format: "%.1f도", motionManager.pitchDegrees))
                    statusRow(title: "Gravity X", value: String(format: "%.2f", motionManager.gravityX))
                    statusRow(title: "Gravity Y", value: String(format: "%.2f", motionManager.gravityY))
                    statusRow(title: "Gravity Z", value: String(format: "%.2f", motionManager.gravityZ))
                    statusRow(title: "흔들림", value: String(format: "%.2fG", motionManager.accelerationMagnitude))
                }
                .padding(20)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(spacing: 12) {
                    Text("가로로 80도 이상 돌리면 프레젠테이션 테스트뷰로 이동합니다.")
                    Text("홈에서 흔들면 제스처 테스트뷰로 이동합니다.")
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .navigationTitle("모션 테스트")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            motionManager.start()
        }
        .onDisappear {
            motionManager.stop()
        }
        .onChange(of: motionManager.pose) { _, pose in
            isPresentationPresented = pose.isLandscape
        }
        .onChange(of: motionManager.latestShakeID) { _, _ in
            guard !isPresentationPresented else { return }
            isGesturePresented = true
        }
        .fullScreenCover(isPresented: $isPresentationPresented) {
            MotionPresentationTestView(motionManager: motionManager)
        }
        .sheet(isPresented: $isGesturePresented) {
            MotionGestureTestView()
        }
    }

    private func statusRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    HomeMotionTestView()
}
