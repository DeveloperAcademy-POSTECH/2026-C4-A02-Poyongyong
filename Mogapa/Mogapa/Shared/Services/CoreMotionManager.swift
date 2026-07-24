//
//  CoreMotionManager.swift
//  Mogapa
//
//  Created by Purple on 7/21/26.
//

import Combine
import CoreMotion
import Foundation

@MainActor
final class CoreMotionManager: ObservableObject {

    @Published
    private(set) var pose: MotionPose = .unknown

    @Published
    private(set) var latestShakeID = UUID()

    @Published
    private(set) var rollDegrees: Double = 0

    @Published
    private(set) var pitchDegrees: Double = 0

    @Published
    private(set) var gravityX: Double = 0

    @Published
    private(set) var gravityY: Double = 0

    @Published
    private(set) var gravityZ: Double = 0

    @Published
    private(set) var accelerationMagnitude: Double = 0

    private let motionManager = CMMotionManager()
    private let updateInterval: TimeInterval = 1.0 / 30.0

    private let landscapeThresholdDegrees = 70.0
    private let flatGravityZThreshold = 0.86
    private let shakeThreshold = 2.2
    private let shakeCooldown: TimeInterval = 0.8

    private var lastShakeDate = Date.distantPast

    func start() {
        guard motionManager.isDeviceMotionAvailable else {
            pose = .unknown
            return
        }

        motionManager.deviceMotionUpdateInterval = updateInterval
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let motion else { return }

            self.updatePose(with: motion)
            self.updateShake(with: motion)
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }

    private func updatePose(with motion: CMDeviceMotion) {
        let gravity = motion.gravity

        gravityX = gravity.x
        gravityY = gravity.y
        gravityZ = gravity.z

        if abs(gravity.z) >= flatGravityZThreshold {
            setPose(.flat)
            return
        }

        let horizontalMagnitude = hypot(gravity.x, gravity.y)
        guard horizontalMagnitude > 0.1 else {
            setPose(.unknown)
            return
        }

        let projectedRoll = atan2(gravity.x, -gravity.y)
        let roll = projectedRoll * 180.0 / .pi
        let pitch = asin(max(-1.0, min(1.0, gravity.z))) * 180.0 / .pi

        rollDegrees = roll
        pitchDegrees = pitch

        if roll <= -landscapeThresholdDegrees {
            setPose(.landscapeLeft)
        } else if roll >= landscapeThresholdDegrees {
            setPose(.landscapeRight)
        } else {
            setPose(.portrait)
        }
    }

    private func updateShake(with motion: CMDeviceMotion) {
        let acceleration = motion.userAcceleration
        let magnitude = sqrt(
            acceleration.x * acceleration.x
            + acceleration.y * acceleration.y
            + acceleration.z * acceleration.z
        )
        accelerationMagnitude = magnitude

        guard magnitude >= shakeThreshold else { return }

        let now = Date()
        guard now.timeIntervalSince(lastShakeDate) >= shakeCooldown else { return }

        lastShakeDate = now
        latestShakeID = UUID()
    }

    private func setPose(_ newPose: MotionPose) {
        guard pose != newPose else { return }
        pose = newPose
    }
}
