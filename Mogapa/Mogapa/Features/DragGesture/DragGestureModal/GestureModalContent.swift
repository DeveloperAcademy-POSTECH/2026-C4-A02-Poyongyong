//
//  GestureModalContent.swift
//  Mogapa
//
//  Created by sun on 7/20/26.
//

import SwiftUI
import SwiftData

struct GestureModalContent: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let title: String
    let onSaved: () -> Void

    @State private var text = ""
    @State private var points: [CGPoint] = []
    @State private var isCanvasFocused = false
    @State private var isTextFieldFocused = false
    @State private var errorMessage: String?

    init(
        title: String,
        onSaved: @escaping () -> Void = {}
    ) {
        self.title = title
        self.onSaved = onSaved
    }

    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 0) {
                header

                content
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .background(Color(.backgroundbgDisabled))
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
                isCanvasFocused = false
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .presentationDetents([.height(725)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(38)
    }

    private var header: some View {
        ModalHeader(
            title: title,
            onClose: {
                dismiss()
            },
            onConfirm: {
                saveGesture()
            }
        )
        .padding(.top, 22)
        .padding(.horizontal, 6)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 14) {
            gesturePhraseSection

            drawingSection

            if let errorMessage {
                Text(errorMessage)
                    .typography(.calloutLight)
                    .foregroundStyle(.red)
            }

            Spacer(minLength: 0)
        }
        .padding(.top, 24)
        .padding(.horizontal, 16)
    }

    private var gesturePhraseSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("제스처 문구")
                .padding(.leading, 6)

            RoundedTextField(text: $text, isEditing: $isTextFieldFocused)
                .frame(maxWidth: .infinity)

            Text(
                """
                드래그 제스처는 자막 없이 음성만 재생돼요.
                이해하기 쉬운, 간단하고 짧은 문구를 추천해요.
                """
            )
            .typography(.calloutLight)
            .foregroundStyle(.texttertiary)
            .padding(.leading, 6)
        }
    }

    private var drawingSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("드래그 제스처")
                .padding(.top, 16)
                .padding(.leading, 6)

            DrawingCanvas(
                points: $points,
                isFocused: $isCanvasFocused
            ) { finishedPoints in
                print("그린 좌표 개수: \(finishedPoints.count)")
            }
            .frame(maxWidth: .infinity)
            .frame(height: 318)
            .allowsHitTesting(!isTextFieldFocused)

            redrawButton
        }
    }

    private func sectionTitle(
        _ title: String
    ) -> some View {
        Text(title)
            .typography(.bodySemiBold)
            .foregroundStyle(.textsecondary)
    }

    private var redrawButton: some View {
        Button {
            points.removeAll()
            isCanvasFocused = false
            errorMessage = nil
        } label: {
            HStack(spacing: 8) {
                Image(
                    systemName:
                        "arrow.trianglehead.counterclockwise"
                )
                .font(
                    .system(
                        size: 20,
                        weight: .medium
                    )
                )

                Text("다시 그리기")
                    .typography(.bodyMedium)
            }
            .foregroundStyle(Color(.textprimary))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .allowsHitTesting(!isTextFieldFocused) 
    }
}

// MARK: - Save

private extension GestureModalContent {

    func saveGesture() {
        errorMessage = nil

        let trimmedText = text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedText.isEmpty else {
            errorMessage = "읽을 문장을 입력해 주세요."
            return
        }

        guard points.count >= 8 else {
            errorMessage = "패턴을 조금 더 길게 그려 주세요."
            return
        }

        let normalizedPoints =
            DragGestureNormalizer.normalize(points)

        guard !normalizedPoints.isEmpty else {
            errorMessage = "패턴을 저장하지 못했습니다."
            return
        }

        let gesture = RegisteredDragGesture(
            phrase: trimmedText,
            points: normalizedPoints,
            sortOrder: nextSortOrder()
        )

        do {
            modelContext.insert(gesture)

            try modelContext.save()

            onSaved()
            dismiss()
        } catch {
            modelContext.rollback()

            errorMessage = "패턴을 저장하지 못했습니다."

            print(
                "드래그 제스처 저장 실패:",
                error
            )
        }
    }

    func nextSortOrder() -> Int {
        var descriptor =
            FetchDescriptor<RegisteredDragGesture>(
                sortBy: [
                    SortDescriptor(
                        \.sortOrder,
                        order: .reverse
                    )
                ]
            )

        descriptor.fetchLimit = 1

        do {
            let lastGesture = try modelContext
                .fetch(descriptor)
                .first

            return (lastGesture?.sortOrder ?? -1) + 1
        } catch {
            print(
                "마지막 정렬 순서 조회 실패:",
                error
            )

            return 0
        }
    }
}
