//
//  FastSpeechDefaultTemplate.swift
//  Mogapa
//
//  Created by Codex on 7/23/26.
//

import Foundation
import SwiftData

enum FastSpeechDefaultTemplate {

    private struct TemplateCategory {
        let name: String
        let phrases: [String]
    }

    private static let categories: [TemplateCategory] = [
        TemplateCategory(
            name: "집",
            phrases: [
                "물 한 잔 주세요",
                "밥 먹고 싶어요",
                "화장실에 가고 싶어요",
                "조금 쉬고 싶어요",
                "불을 꺼주세요",
                "문을 열어주세요",
                "지금은 혼자 있고 싶어요",
                "도와줘서 고마워요"
            ]
        ),
        TemplateCategory(
            name: "학교",
            phrases: [
                "선생님께 질문이 있어요",
                "다시 설명해 주세요",
                "쉬는 시간이 필요해요",
                "친구와 같이 하고 싶어요",
                "필기할 시간이 필요해요",
                "화장실에 다녀와도 될까요?",
                "발표는 조금 천천히 하고 싶어요",
                "오늘 숙제가 무엇인지 알려주세요"
            ]
        ),
        TemplateCategory(
            name: "직장",
            phrases: [
                "회의 시간을 확인하고 싶어요",
                "잠시 후에 다시 말씀드릴게요",
                "자료를 먼저 확인해보겠습니다",
                "도움이 필요하면 알려주세요",
                "오늘 일정이 어떻게 되나요?",
                "잠깐 쉬는 시간이 필요해요",
                "이 내용은 메모로 남겨주세요",
                "마감 시간을 다시 알려주세요"
            ]
        )
    ]

    static func seedIfNeeded(
        in container: ModelContainer
    ) {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<FastSpeechCategory>()

        do {
            guard try context.fetchCount(descriptor) == 0 else {
                return
            }

            seed(in: context)
            try context.save()
        } catch {
            print("빠른 말하기 기본 템플릿 생성 실패: \(error)")
        }
    }

    private static func seed(
        in context: ModelContext
    ) {
        let now = Date()

        for (categoryIndex, templateCategory) in categories.enumerated() {
            let category = FastSpeechCategory(
                name: templateCategory.name,
                sortOrder: categoryIndex
            )

            context.insert(category)

            for (phraseIndex, text) in templateCategory.phrases.enumerated() {
                let phrase = FastSpeechPhrase(
                    text: text,
                    sortOrder: phraseIndex,
                    category: category,
                    createdAt: now.addingTimeInterval(
                        TimeInterval(
                            -((categoryIndex * 100) + phraseIndex)
                        )
                    )
                )

                context.insert(phrase)
            }
        }
    }
}
