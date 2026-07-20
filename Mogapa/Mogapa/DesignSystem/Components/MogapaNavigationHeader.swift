//
//  MogapaNavigationHeader.swift
//  Mogapa
//
//  Created by Codex on 7/20/26.
//

import SwiftUI
import UIKit

struct MogapaNavigationHeader: View {
    let title: String
    let rightTitle: String
    let leftIcon: String
    let leftAccessibilityLabel: String
    let onLeftTap: () -> Void
    let onRightTap: () -> Void

    init(
        title: String,
        rightTitle: String,
        leftIcon: String = "chevron.left",
        leftAccessibilityLabel: String = "뒤로 가기",
        onLeftTap: @escaping () -> Void,
        onRightTap: @escaping () -> Void
    ) {
        self.title = title
        self.rightTitle = rightTitle
        self.leftIcon = leftIcon
        self.leftAccessibilityLabel = leftAccessibilityLabel
        self.onLeftTap = onLeftTap
        self.onRightTap = onRightTap
    }

    var body: some View {
        ZStack {
            Text(title)
                .typography(.title2Medium)
                .foregroundStyle(.textprimary)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            HStack {
                BasicButton(
                    systemImage: leftIcon,
                    shape: .circle,
                    foregroundStyle: .textprimary,
                    font: .system(size: 24, weight: .medium)
                ) {
                    onLeftTap()
                }
                .accessibilityLabel(Text(leftAccessibilityLabel))

                Spacer()

                BasicButton(
                    title: rightTitle,
                    shape: .capsule,
                    foregroundStyle: .textsecondary,
                    font: .pretendard(.medium, size: 20)
                ) {
                    onRightTap()
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 56)
        .padding(.bottom, 10)
        .background(Color(uiColor: UIColor(red: 1, green: 1, blue: 1, alpha: 1)))
    }
}

#Preview("기본 헤더") {
    MogapaNavigationHeader(
        title: "빠른 말하기",
        rightTitle: "선택",
        onLeftTap: {},
        onRightTap: {}
    )
    .environment(\.locale, Locale(identifier: "ko"))
}

#Preview("편집 진입 형태") {
    MogapaNavigationHeader(
        title: "빠른 말하기",
        rightTitle: "삭제",
        leftIcon: "xmark",
        leftAccessibilityLabel: "닫기",
        onLeftTap: {},
        onRightTap: {}
    )
    .environment(\.locale, Locale(identifier: "ko"))
}
