//
//  DragGestureEditDummyData.swift
//  Mogapa
//
//  Created by sun on 7/23/26.
//

import Foundation

enum DragGestureEditDummyData {

    static func make() -> [RegisteredDragGesture] {
        [
            RegisteredDragGesture(
                phrase: "잠시만 기다려 주세요.",
                sortOrder: 0
            ),
            RegisteredDragGesture(
                phrase: "도와주셔서 감사합니다.",
                sortOrder: 1
            ),
            RegisteredDragGesture(
                phrase: "한 번만 다시 말씀해 주세요.",
                sortOrder: 2
            ),
            RegisteredDragGesture(
                phrase: "조금 천천히 말씀해 주세요.",
                sortOrder: 3
            ),
            RegisteredDragGesture(
                phrase: "지금은 통화가 어려워서 문자로 부탁드려요.",
                sortOrder: 4
            )
        ]
    }
}
