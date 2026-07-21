//
//  GestureModalContent.swift
//  Mogapa
//
//  Created by sun on 7/20/26.
//

import SwiftUI

struct GestureModalContent: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let title: String

    @State private var text = ""
    @State private var points: [CGPoint] = []
    @State private var isCanvasFocused = false
    @State private var errorMessage: String?

    var body: some View {
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

            RoundedTextField(text: $text)
                .frame(maxWidth: .infinity)

            Text(
                """
                드래그 제스처는 자막 없이 음성만 재생돼요.
                이해하기 쉬운, 간단하고 짧은 문구를 추천해요.
                """
            )
            .typography(.calloutLight)
            .foregroundStyle(.texttertiary)
        }
    }

    private var drawingSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("드래그 제스처")
                .padding(.top, 16)

            DrawingCanvas(
                points: $points,
                isFocused: $isCanvasFocused
            ) { finishedPoints in
                print("그린 좌표 개수: \(finishedPoints.count)")
            }
            .frame(maxWidth: .infinity)
            .frame(height: 318)

            redrawButton
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .typography(.bodySemiBold)
            .foregroundStyle(.textsecondary)
    }

    private var redrawButton: some View {
        Button {
            points.removeAll()
            isCanvasFocused = false
        } label: {
            HStack(spacing: 8) {
                Image(
                    systemName:
                        "arrow.trianglehead.counterclockwise"
                )
                .font(.system(size: 20, weight: .medium))

                Text("다시 그리기")
                    .typography(.bodyMedium)
            }
            .foregroundStyle(Color(.textprimary))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

// MARK: - Save

private extension GestureModalContent {

    func saveGesture() {
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

        let normalizedPoints = DragGestureNormalizer.normalize(points)

        guard !normalizedPoints.isEmpty else {
            errorMessage = "패턴을 저장하지 못했습니다."
            return
        }

        let gesture = RegisteredDragGesture(
            name: trimmedText,
            phrase: trimmedText,
            points: normalizedPoints
        )

        do {
            try DragGestureRepository(modelContext: modelContext).insertGesture(gesture)
            dismiss()
        } catch {
            errorMessage = "패턴을 저장하지 못했습니다."
        }
    }
}
