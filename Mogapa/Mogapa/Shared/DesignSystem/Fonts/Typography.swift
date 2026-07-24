//
//  Typography.swift
//  Mogapa
//
//  Created by JENNA on 7/17/26.
//

import SwiftUI

enum Typography {
    case presentBodyMedium, presentBodyBold
    case largeTitleMedium, largeTitleBold
    case titleMedium, titleBold
    case subTitleMedium, subTitleBold
    case bodyRegular, bodyMedium, bodySemiBold, bodyBold
    case subheadlineMedium, subheadlineBold
    case calloutLight, calloutRegular

    var weight: PretendardWeight {
            switch self {
            case .presentBodyMedium, .largeTitleMedium, .titleMedium, .subTitleMedium, .bodyMedium, .subheadlineMedium:
                return .medium
            case .bodyRegular, .calloutRegular:
                return .regular
            case .calloutLight:
                return .light
            case .bodySemiBold:
                return .semiBold
            default:
                return .bold
            }
        }
    
    var size: CGFloat {
            switch self {
            case .presentBodyMedium, .presentBodyBold: return 40
            case .largeTitleMedium, .largeTitleBold: return 32
            case .titleMedium, .titleBold: return 24
            case .subTitleMedium, .subTitleBold: return 20
            case .bodyMedium, .bodySemiBold, .bodyBold, .bodyRegular: return 16
            case .subheadlineMedium, .subheadlineBold: return 14
            case .calloutRegular, .calloutLight: return 12
            }
        }
    
    var letterSpacingPercent: CGFloat { -2 }
    
    // 행간 설정
    var lineHeight: CGFloat {
            switch self {
            case .presentBodyMedium, .presentBodyBold: return 52
            default: return size
            }
        }
}

extension View {
    func typography(_ typography: Typography) -> some View {
        self
            .font(.pretendard(typography.weight, size: typography.size))
            .tracking(typography.size * typography.letterSpacingPercent / 100)
            .lineSpacing(typography.lineHeight - typography.size)
    }
}
