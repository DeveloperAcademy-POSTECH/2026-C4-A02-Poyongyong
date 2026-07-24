//
//  MotionPose.swift
//  Mogapa
//
//  Created by Purple on 7/21/26.
//

import Foundation

enum MotionPose: Equatable {
    case portrait
    case landscapeLeft
    case landscapeRight
    case flat
    case unknown
}

extension MotionPose {
    var isLandscape: Bool {
        switch self {
        case .landscapeLeft, .landscapeRight:
            true
        case .portrait, .flat, .unknown:
            false
        }
    }

    var displayName: String {
        switch self {
        case .portrait:
            "세로"
        case .landscapeLeft:
            "좌측 가로"
        case .landscapeRight:
            "우측 가로"
        case .flat:
            "바닥"
        case .unknown:
            "알 수 없음"
        }
    }
}
