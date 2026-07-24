//
//  DragIndicator.swift
//  Mogapa
//
//  Created by Sue on 7/21/26.
//

import SwiftUI

enum DragState {
    case none
    case failed
    case succeeded
}

extension DragState {

    var backgroundColor: Color {
        switch self {
        case .none: .white.opacity(0.3)
        case .failed: .red.opacity(0.6)
        case .succeeded: .green.opacity(0.6)
        }
    }

    var iconName: String? {
        switch self {
        case .none: nil
        case .failed: "😭"
        case .succeeded: "☺️"
        }
    }
}

struct DragIndicator: View {
    let title: String
    let state: DragState

    init(title: String, state: DragState) {
        self.title = title
        self.state = state
    }

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .background(state.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(alignment: .trailing) {
                if let iconName = state.iconName {
                    Text(iconName)
                        .foregroundStyle(.white)
                        .padding(.trailing, 16)
                }
            }
    }
}

#Preview {
    VStack(spacing: 12) {
        DragIndicator(title: "하이하이", state: .none)
        DragIndicator(title: "하이하이", state: .failed)
        DragIndicator(title: "하이하이", state: .succeeded)
    }
    .padding()
    .background(.black.opacity(0.75))
}
