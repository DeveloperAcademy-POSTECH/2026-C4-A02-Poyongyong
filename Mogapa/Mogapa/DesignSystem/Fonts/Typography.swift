//
//  Typography.swift
//  Mogapa
//
//  Created by JENNA on 7/17/26.
//

import SwiftUI

enum Typography {
    case largeTitleMedium, largeTitleBold
    case largeTitle1Medium, largeTitle1Bold
    case title1Medium, title1Bold
    case title2Medium, title2Bold
    case bodyMedium, bodySemiBold, bodyBold
    case subheadlineMedium, subheadlineBold
    case calloutMedium, calloutBold

    var weight: PretendardWeight {
            switch self {
            case .largeTitleMedium, .largeTitle1Medium, .title1Medium, .title2Medium,
                 .bodyMedium, .subheadlineMedium, .calloutMedium:
                return .medium
            case .bodySemiBold:
                return .semiBold
            default:
                return .bold
            }
        }
    
    var size: CGFloat {
            switch self {
            case .largeTitleMedium, .largeTitleBold: return 40
            case .largeTitle1Medium, .largeTitle1Bold: return 32
            case .title1Medium, .title1Bold: return 24
            case .title2Medium, .title2Bold: return 20
            case .bodyMedium, .bodySemiBold, .bodyBold: return 16
            case .subheadlineMedium, .subheadlineBold: return 14
            case .calloutMedium, .calloutBold: return 12
            }
        }
    
    var letterSpacingPercent: CGFloat { -2 }
}

extension View {
    func style(_ typography: Typography) -> some View {
        self
            .font(.pretendard(typography.weight, size: typography.size))
            .tracking(typography.size * typography.letterSpacingPercent / 100)
    }
}
