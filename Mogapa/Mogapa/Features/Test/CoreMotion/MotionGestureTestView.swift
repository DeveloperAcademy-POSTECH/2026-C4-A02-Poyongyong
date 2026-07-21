//
//  MotionGestureTestView.swift
//  Mogapa
//
//  Created by Purple on 7/21/26.
//

import SwiftUI

struct MotionGestureTestView: View {

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            Text("흔들기 감지됨")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.primary)

            Button {
                dismiss()
            } label: {
                Text("나가기")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    MotionGestureTestView()
}
