//
//  GestureReorderDropDelegate.swift
//  Mogapa
//
//  Created by sun on 7/23/26.
//

import SwiftUI

struct GestureReorderDropDelegate:
    DropDelegate {

    let destinationID: UUID
    let draggingID: UUID?
    let onMove: () -> Void
    let onFinish: () -> Void

    func dropEntered(
        info: DropInfo
    ) {
        guard
            let draggingID,
            draggingID != destinationID
        else {
            return
        }

        withAnimation(.snappy) {
            onMove()
        }
    }

    func dropUpdated(
        info: DropInfo
    ) -> DropProposal? {
        DropProposal(
            operation: .move
        )
    }

    func performDrop(
        info: DropInfo
    ) -> Bool {
        onFinish()

        return true
    }

    func dropExited(
        info: DropInfo
    ) {
    }
}
