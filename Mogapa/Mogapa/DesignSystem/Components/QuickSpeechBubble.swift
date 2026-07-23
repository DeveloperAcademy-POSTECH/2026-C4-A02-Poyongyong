//
//  QuickSpeechBubble.swift
//  Mogapa
//
//  Created by Purple on 7/21/26.
//

import SwiftUI

struct QuickSpeechBubble: View {
    let text: String
    let isEditing: Bool
    let preservedLineLimit: Int?
    let onLineLimitMeasured: ((Int) -> Void)?
    let action: (() -> Void)?

    @State private var measuredLineLimit: Int?

    private let minHeight: CGFloat = 59
    private let cornerRadius: CGFloat = 40
    private let horizontalSpacing: CGFloat = 10
    private let leadingPadding: CGFloat = 24
    private let trailingPadding: CGFloat = 28
    private let verticalPadding: CGFloat = 20
    private let bodyMediumLineHeight: CGFloat = 19

    init(
        text: String,
        isEditing: Bool = false,
        preservedLineLimit: Int? = nil,
        onLineLimitMeasured: ((Int) -> Void)? = nil,
        action: (() -> Void)? = nil
    ) {
        self.text = text
        self.isEditing = isEditing
        self.preservedLineLimit = preservedLineLimit
        self.onLineLimitMeasured = onLineLimitMeasured
        self.action = action
    }

    var body: some View {
        Group {
            if let action, !isEditing {
                Button(action: action) {
                    bubbleContent
                }
                .buttonStyle(.plain)
            } else {
                bubbleContent
            }
        }
    }

    private var bubbleContent: some View {
        HStack(alignment: .top, spacing: horizontalSpacing) {
            Text(text)
                .typography(.bodyMedium)
                .foregroundStyle(.textprimary)
                .multilineTextAlignment(.leading)
                .lineLimit(isEditing ? preservedLineLimit ?? measuredLineLimit : nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.leading, leadingPadding)
        .padding(.trailing, trailingPadding)
        .padding(.vertical, verticalPadding)
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
        .background {
            bubbleShape
                .fill(.backgroundbgSpBubble)
        }
        .overlay {
            bubbleShape
                .inset(by: 0.5)
                .stroke(.strokedefault, lineWidth: 1)
        }
        .background {
            if !isEditing {
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: QuickSpeechBubbleHeightPreferenceKey.self,
                            value: proxy.size.height
                        )
                }
            }
        }
        .onPreferenceChange(QuickSpeechBubbleHeightPreferenceKey.self) { height in
            guard !isEditing, height > 0 else { return }

            let textHeight = max(0, height - verticalPadding * 2)
            let lineCount = max(1, Int((textHeight / bodyMediumLineHeight).rounded()))

            guard measuredLineLimit != lineCount else { return }

            measuredLineLimit = lineCount
            onLineLimitMeasured?(lineCount)
        }
    }

    private var bubbleShape: some InsettableShape {
        UnevenRoundedRectangle(
            topLeadingRadius: 0,
            bottomLeadingRadius: cornerRadius,
            bottomTrailingRadius: cornerRadius,
            topTrailingRadius: cornerRadius
        )
    }
}

private struct QuickSpeechBubbleHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview("기본") {
    VStack(spacing: 10) {
        QuickSpeechBubble(text: "텍스트 입력")

        QuickSpeechBubble(
            text: "얼마나 길게 써지나 함 봐볼까요. 근데 이거 길게 쓰면 밑으로 내려가네요."
        )
    }
    .padding(.horizontal, 20)
    .environment(\.locale, Locale(identifier: "ko"))
}

#Preview("버튼") {
    QuickSpeechBubble(text: "텍스트 입력", action: {})
        .padding(.horizontal, 20)
        .environment(\.locale, Locale(identifier: "ko"))
}

#Preview("편집") {
    VStack{
        QuickSpeechBubble(
            text: "얼마나 길게 써지나 함 봐볼까요. 근데 이거 길게 쓰면 밑으로 내려가네요. 딱 맞춰서 이어지는지!!! ",
        )
        VStack(spacing: 10) {
            
            
            QuickSpeechBubble(
                text: "얼마나 길게 써지나 함 봐볼까요. 근데 이거 길게 쓰면 밑으로 내려가네요. 딱 맞춰서 이어지는지",
                isEditing: true,
                preservedLineLimit: 2
            )
            
            QuickSpeechBubble(
                text: "텍스트 입력",
            )
        }
        .padding(.leading, 30)
        
        .environment(\.locale, Locale(identifier: "ko"))
    }  .padding(.horizontal, 20)
}
