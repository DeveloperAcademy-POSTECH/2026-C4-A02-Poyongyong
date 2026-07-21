//
//  FastSpeechViewDummyData.swift
//  Mogapa
//
//  Created by Purple on 7/22/26.
//

import Foundation

struct FastSpeechViewPhrase: Identifiable {
    let id: UUID
    var text: String
    var categoryID: UUID?
    var isPinned: Bool

    init(
        id: UUID = UUID(),
        text: String,
        categoryID: UUID? = nil,
        isPinned: Bool = false
    ) {
        self.id = id
        self.text = text
        self.categoryID = categoryID
        self.isPinned = isPinned
    }
}

enum FastSpeechViewDummyData {
    static func make() -> (
        categories: [FastSpeechCategory],
        phrases: [FastSpeechViewPhrase]
    ) {
        let workCategory = FastSpeechCategory(name: "직장", sortOrder: 0)
        let schoolCategory = FastSpeechCategory(name: "학교", sortOrder: 1)
        let hospitalCategory = FastSpeechCategory(name: "병원", sortOrder: 2)

        return (
            categories: [
                workCategory,
                schoolCategory,
                hospitalCategory
            ],
            phrases: [
                FastSpeechViewPhrase(
                    text: "잠시만 기다려 주세요. 천천히 말씀드릴게요.",
                    categoryID: nil,
                    isPinned: true
                ),
                FastSpeechViewPhrase(
                    text: "제가 듣고 이해하는 데 시간이 조금 필요해요.",
                    categoryID: nil,
                    isPinned: true
                ),
                FastSpeechViewPhrase(
                    text: "회의 자료는 메일로 다시 공유해 주세요.",
                    categoryID: workCategory.id
                ),
                FastSpeechViewPhrase(
                    text: "오늘 일정 확인하고 다시 말씀드릴게요.",
                    categoryID: workCategory.id
                ),
                FastSpeechViewPhrase(
                    text: "지금은 통화가 어려워서 문자로 부탁드려요.",
                    categoryID: workCategory.id
                ),
                FastSpeechViewPhrase(
                    text: "수업 끝나고 다시 연락드릴게요.",
                    categoryID: schoolCategory.id
                ),
                FastSpeechViewPhrase(
                    text: "과제 제출 기한을 한 번 더 알려주세요.",
                    categoryID: schoolCategory.id
                ),
                FastSpeechViewPhrase(
                    text: "어디가 아픈지 천천히 설명드릴게요.",
                    categoryID: hospitalCategory.id
                ),
                FastSpeechViewPhrase(
                    text: "복용 방법을 종이에 적어주실 수 있나요?",
                    categoryID: hospitalCategory.id
                ),
                FastSpeechViewPhrase(
                    text: "네, 알겠습니다.",
                    categoryID: nil
                ),
                FastSpeechViewPhrase(
                    text: "괜찮아요. 도와주셔서 감사합니다.",
                    categoryID: nil
                )
            ]
        )
    }
}
