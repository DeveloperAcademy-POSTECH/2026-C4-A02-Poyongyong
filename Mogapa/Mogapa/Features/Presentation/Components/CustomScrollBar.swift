//
//  CustomScrollBar.swift
//  Mogapa
//
//  Created by Sue on 7/22/26.
//

import SwiftUI

struct CustomScrollBar: View {
    let contentHeight: CGFloat
    let scrollOffset: CGFloat
    let containerHeight: CGFloat

    var body: some View {
        let visibleRatio = contentHeight > 0
            ? min(containerHeight / contentHeight, 1)
            : 1
        let thumbHeight = max(containerHeight * visibleRatio, 24)
        let maxScrollable = max(contentHeight - containerHeight, 1)
        let scrollProgress = min(max(scrollOffset / maxScrollable, 0), 1)
        let thumbOffsetY = (containerHeight - thumbHeight) * scrollProgress
        
        ZStack(alignment: .top) {
            Capsule()
                .fill(
                    Color("Backgroundbg-sp-bubble").opacity(0.4)
                )
                .frame(width: 8, height: containerHeight)

            Capsule()
                .fill(
                    Color("Backgroundbg-sp-bubble").opacity(0.9)
                )
                .frame(width: 8, height: thumbHeight)
                .offset(y: thumbOffsetY)
        }
        .opacity(contentHeight > containerHeight ? 1 : 0)
    }
}


#Preview {
    ZStack(alignment: .trailing) {
        Color.black

        CustomScrollBar(
            contentHeight: 2000,
            scrollOffset: -600,
            containerHeight: 600
        )
    }
    .frame(width: 60, height: 600)
}
