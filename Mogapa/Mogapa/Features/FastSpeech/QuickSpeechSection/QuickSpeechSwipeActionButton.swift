//
//  QuickSpeechSwipeActionButton.swift
//  Mogapa
//
//  Created by Purple on 7/21/26.
//

import SwiftUI
import DeveloperToolsSupport

enum QuickSpeechSwipeAction {
    case pin
    case unpin
    case delete

    var iconResource: ImageResource {
        switch self {
        case .pin:
            .quickSpeechPin
        case .unpin:
            .quickSpeechPinSlash
        case .delete:
            .quickSpeechTrash
        }
    }

    var backgroundStyle: Color {
        switch self {
        case .pin, .unpin:
            .accentsOrange
        case .delete:
            .accentsRed
        }
    }
}

struct QuickSpeechSwipeActionButton: View {
    let actionType: QuickSpeechSwipeAction
    let action: () -> Void

    init(
        _ actionType: QuickSpeechSwipeAction,
        action: @escaping () -> Void
    ) {
        self.actionType = actionType
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(actionType.backgroundStyle)

                Image(actionType.iconResource)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(height: 20)
                    .foregroundStyle(.iconinverse)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .contentShape(Circle())
        }
        .frame(width: 50, height: 50)
        .buttonStyle(.plain)
        .clipShape(Circle())
        .contentShape(Circle())
    }
}

#Preview("QuickSpeechSwipeActionButton") {
    HStack(spacing: 16) {
        QuickSpeechSwipeActionButton(.pin) {}
        QuickSpeechSwipeActionButton(.unpin) {}
        QuickSpeechSwipeActionButton(.delete) {}
    }
    .padding()
    .environment(\.locale, Locale(identifier: "ko"))
}
