//
//  Font+Pretendard.swift
//  Mogapa
//
//  Created by JENNA on 7/17/26.
//

import SwiftUI

enum PretendardWeight: String {
    case medium = "Pretendard-Medium"
    case semiBold = "Pretendard-SemiBold"
    case bold = "Pretendard-Bold"
    case light = "Pretendard-Light"
    case regular = "Pretendard-regular"
}

extension Font {
    static func pretendard(_ weight: PretendardWeight, size: CGFloat) -> Font {
        .custom(weight.rawValue, size: size)
    }
}
