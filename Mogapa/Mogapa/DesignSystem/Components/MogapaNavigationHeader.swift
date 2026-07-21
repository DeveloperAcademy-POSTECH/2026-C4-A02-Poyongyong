//
//  MogapaNavigationHeader.swift
//  Mogapa
//
//  Created by Purple on 7/20/26.
//

import SwiftUI

struct MogapaNavigationHeader: View {
    let title: String
    let rightTitle: String?
    let rightSystemImage: String?
    let isRightDisabled: Bool
    let rightTint: Color
    let rightForegroundStyle: AnyShapeStyle
    let leftTitle: String?
    let leftIcon: String?
    let leftAccessibilityLabel: String
    let onLeftTap: () -> Void
    let onRightTap: () -> Void
    let backgroundColor: Color // 헤더 색상 다른 뷰에서 변경 가능하게 수정

    init(
        title: String,
        rightTitle: String? = nil,
        rightSystemImage: String? = nil,
        isRightDisabled: Bool = false,
        rightTint: Color = .clear,
        rightForegroundStyle: some ShapeStyle = .textsecondary,
        leftTitle: String? = nil,
        leftIcon: String? = "chevron.left",
        leftAccessibilityLabel: String = "뒤로 가기",
        onLeftTap: @escaping () -> Void,
        onRightTap: @escaping () -> Void,
        backgroundColor: Color = .backgroundbgCanvas
    ) {
        self.title = title
        self.rightTitle = rightTitle
        self.rightSystemImage = rightSystemImage
        self.isRightDisabled = isRightDisabled
        self.rightTint = rightTint
        self.rightForegroundStyle = AnyShapeStyle(rightForegroundStyle)
        self.leftTitle = leftTitle
        self.leftIcon = leftIcon
        self.leftAccessibilityLabel = leftAccessibilityLabel
        self.onLeftTap = onLeftTap
        self.onRightTap = onRightTap
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        ZStack {
            Text(title)
                .typography(.subTitleMedium)
                .foregroundStyle(.textprimary)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            HStack {
                BasicButton(
                    title: leftTitle,
                    systemImage: leftIcon,
                    shape: leftTitle == nil ? .circle : .capsule,
                    foregroundStyle: leftTitle == nil ? .textprimary : .textsecondary,
                    font: leftTitle == nil ? .system(size: 24, weight: .medium) : .pretendard(.medium, size: 20)
                ) {
                    onLeftTap()
                }
                .accessibilityLabel(Text(leftAccessibilityLabel))

                Spacer()

                BasicButton(
                    title: rightTitle,
                    systemImage: rightSystemImage,
                    shape: .capsule,
                    foregroundStyle: rightForegroundStyle,
                    tint: rightTint,
                    font: .pretendard(.medium, size: 20)
                ) {
                    onRightTap()
                }
                .disabled(isRightDisabled)
                .opacity(isRightDisabled ? 0.45 : 1)
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 56)
        .padding(.bottom, 10)
        .background(backgroundColor)
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
        rightSystemImage: "trash.fill",
        rightTint: .accentsRed,
        rightForegroundStyle: .iconinverse,
        leftTitle: "취소",
        leftIcon: nil,
        leftAccessibilityLabel: "닫기",
        onLeftTap: {},
        onRightTap: {}
    )
    .environment(\.locale, Locale(identifier: "ko"))
}
