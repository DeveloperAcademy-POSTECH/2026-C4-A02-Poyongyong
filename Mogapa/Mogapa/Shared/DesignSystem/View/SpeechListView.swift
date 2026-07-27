//
//  SpeechListView.swift
//  Mogapa
//
//  Created by sun on 7/27/26.
//

import SwiftUI

struct SpeechListView<Content: View>: View {

    // MARK: - Properties

    let title: String

    let isEditing: Bool
    let hasSelection: Bool

    let createButtonBottomPadding: CGFloat

    let onBack: () -> Void
    let onCancelEditing: () -> Void
    let onStartEditing: () -> Void
    let onDeleteSelected: () -> Void
    let onCreate: () -> Void

    private let content: Content

    // MARK: - Initializer

    init(
        title: String,
        isEditing: Bool,
        hasSelection: Bool,
        createButtonBottomPadding: CGFloat = 20,
        onBack: @escaping () -> Void,
        onCancelEditing: @escaping () -> Void,
        onStartEditing: @escaping () -> Void,
        onDeleteSelected: @escaping () -> Void,
        onCreate: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.isEditing = isEditing
        self.hasSelection = hasSelection
        self.createButtonBottomPadding =
            createButtonBottomPadding

        self.onBack = onBack
        self.onCancelEditing = onCancelEditing
        self.onStartEditing = onStartEditing
        self.onDeleteSelected = onDeleteSelected
        self.onCreate = onCreate

        self.content = content()
    }

    // MARK: - Body

    var body: some View {
        ZStack(
            alignment: .bottomTrailing
        ) {
            VStack(
                spacing: 18
            ) {
                header

                content
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )

            if !isEditing {
                CreateButton(
                    action: onCreate
                )
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .bottomTrailing
                )
                .padding(
                    .trailing,
                    20
                )
                .padding(
                    .bottom,
                    createButtonBottomPadding
                )
            }
        }
        .background(
            Color.backgroundbgCanvas
        )
        .navigationBarBackButtonHidden(
            true
        )
        .toolbar(
            .hidden,
            for: .navigationBar
        )
    }
}

// MARK: - Header

private extension SpeechListView {

    var header: some View {
        MogapaNavigationHeader(
            title: title,
            rightTitle:
                isEditing
                ? nil
                : "편집",
            rightSystemImage:
                isEditing
                ? "trash.fill"
                : nil,
            isRightDisabled:
                isEditing &&
                !hasSelection,
            isRightProminent:
                isEditing &&
                hasSelection,
            rightTint:
                isEditing &&
                hasSelection
                ? .accentsRed
                : .clear,
            rightForegroundStyle:
                rightForegroundStyle,
            leftTitle:
                isEditing
                ? "취소"
                : nil,
            leftIcon:
                isEditing
                ? nil
                : "chevron.left",
            leftAccessibilityLabel:
                isEditing
                ? "편집 종료"
                : "뒤로 가기",
            onLeftTap:
                handleLeftTap,
            onRightTap:
                handleRightTap
        )
    }

    var rightForegroundStyle: AnyShapeStyle {
        if !isEditing {
            return AnyShapeStyle(
                .textsecondary
            )
        }

        return hasSelection
            ? AnyShapeStyle(.iconinverse)
            : AnyShapeStyle(.textmuted)
    }
}

// MARK: - Actions

private extension SpeechListView {

    func handleLeftTap() {
        if isEditing {
            withAnimation(
                .snappy
            ) {
                onCancelEditing()
            }

            return
        }

        onBack()
    }

    func handleRightTap() {
        withAnimation(
            .snappy
        ) {
            if isEditing {
                onDeleteSelected()
            } else {
                onStartEditing()
            }
        }
    }
}
