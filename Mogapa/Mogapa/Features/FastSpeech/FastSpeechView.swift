//
//  FastSpeechView.swift
//  Mogapa
//
//  Created by Purple on 7/22/26.
//

import SwiftData
import SwiftUI

struct FastSpeechView: View {

    // MARK: - Environment

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var modelContext

    // MARK: - SwiftData

    @Query(
        sort: [
            SortDescriptor(
                \FastSpeechCategory.sortOrder,
                order: .forward
            )
        ]
    )
    private var categories: [FastSpeechCategory]

    @Query(
        sort: [
            SortDescriptor(
                \FastSpeechPhrase.createdAt,
                order: .reverse
            )
        ]
    )
    private var phrases: [FastSpeechPhrase]

    // MARK: - ViewModel

    @State
    private var viewModel =
        FastSpeechViewModel()

    // MARK: - Body

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack(
            alignment: .bottomTrailing
        ) {
            VStack(spacing: 18) {
                header

                FastSpeechCategorySelector(
                    categories: categories,
                    selectedIndex:
                        $viewModel.selectedCategoryIndex,
                    defaultTitle: "최근 문구",
                    showsAddButton: true,
                    isEditing: viewModel.isEditing,
                    onAddCategory: { name in
                        withAnimation(.snappy) {
                            viewModel.addCategory(
                                name,
                                categories: categories,
                                modelContext: modelContext
                            )
                        }
                    },
                    onAddingStateChange: { isAdding in
                        withAnimation(.snappy) {
                            viewModel
                                .updateAddingCategoryState(
                                    isAdding
                                )
                        }
                    },
                    onDeleteCategory: {
                        viewModel
                            .presentDeleteCategoryAlert($0)
                    }
                )
                .padding(.horizontal, 20)

                ZStack(alignment: .top) {
                    QuickSpeechBubbleList(
                        items: viewModel.bubbleItems(
                            categories: categories,
                            phrases: phrases
                        ),
                        isEditing: viewModel.isEditing,
                        allowsMove:
                            viewModel.canMoveSelectedPhrases,
                        allowsFullSwipeDelete: true,
                        selectedIDs:
                            $viewModel.selectedIDs,
                        onTap: { id in
                            viewModel.presentEditModal(
                                phraseID: id,
                                phrases: phrases
                            )
                        },
                        onDelete: { id in
                            withAnimation(.snappy) {
                                viewModel.deletePhrase(
                                    id,
                                    phrases: phrases,
                                    modelContext:
                                        modelContext
                                )
                            }
                        },
                        onMove: { source, destination in
                            withAnimation(.snappy) {
                                viewModel.movePhrases(
                                    from: source,
                                    to: destination,
                                    categories: categories,
                                    phrases: phrases,
                                    modelContext:
                                        modelContext
                                )
                            }
                        }
                    )

                    if viewModel
                        .showsEmptyCategoryMessage(
                            categories: categories,
                            phrases: phrases
                        ) {
                        emptyCategoryMessage
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )

            if !viewModel.isEditing {
                CreateButton {
                    viewModel.presentAddModal()
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .bottomTrailing
                )
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
        .background(.backgroundbgCanvas)
        .navigationBarBackButtonHidden(true)
        .toolbar(
            .hidden,
            for: .navigationBar
        )
        .onChange(
            of: categories.count
        ) { _, count in
            viewModel.adjustSelectedCategoryIndex(
                categoryCount: count
            )
        }
        .onChange(
            of: viewModel.selectedCategoryIndex
        ) { _, _ in
            viewModel.selectCategoryChanged()
        }
        .sheet(
            item: $viewModel.presentedModal
        ) { modal in
            SpeechModalContent(
                title: modal.title,
                categories:
                    viewModel.categoryNames(
                        from: categories
                    ),
                existingText:
                    modal.existingText,
                initialCategory:
                    viewModel.initialCategoryName(
                        for: modal,
                        categories: categories
                    ),
                onConfirm: { text, categoryName in
                    withAnimation(.snappy) {
                        viewModel.handleModalConfirm(
                            modal,
                            text: text,
                            categoryName: categoryName,
                            categories: categories,
                            phrases: phrases,
                            modelContext: modelContext
                        )
                    }
                }
            )
        }
        .customAlert(
            isPresented:
                $viewModel
                    .isCategoryDeleteAlertPresented,
            title:
                viewModel.categoryDeleteAlertTitle,
            message:
                "카테고리 내 문구들도 한번에 지워집니다.",
            onConfirm: {
                withAnimation(.snappy) {
                    viewModel.confirmDeleteCategory(
                        categories: categories,
                        modelContext: modelContext
                    )
                }
            }
        )
    }
}

// MARK: - Header

private extension FastSpeechView {

    var header: some View {
        MogapaNavigationHeader(
            title: "빠른 말하기",
            rightTitle:
                viewModel.isEditing
                ? nil
                : "편집",
            rightSystemImage:
                viewModel.isEditing
                ? "trash.fill"
                : nil,
            isRightDisabled:
                viewModel.isEditing &&
                viewModel.selectedIDs.isEmpty,
            isRightProminent:
                viewModel.isEditing &&
                !viewModel.selectedIDs.isEmpty,
            rightTint:
                viewModel.isEditing &&
                !viewModel.selectedIDs.isEmpty
                ? .accentsRed
                : .clear,
            rightForegroundStyle:
                rightForegroundStyle,
            leftTitle:
                viewModel.isEditing
                ? "취소"
                : nil,
            leftIcon:
                viewModel.isEditing
                ? nil
                : "chevron.left",
            leftAccessibilityLabel:
                viewModel.isEditing
                ? "편집 종료"
                : "뒤로 가기",
            onLeftTap: handleLeftTap,
            onRightTap: handleRightTap
        )
    }

    var rightForegroundStyle: AnyShapeStyle {
        if !viewModel.isEditing {
            return AnyShapeStyle(
                .textsecondary
            )
        }

        return viewModel.selectedIDs.isEmpty
            ? AnyShapeStyle(.textmuted)
            : AnyShapeStyle(.iconinverse)
    }

    var emptyCategoryMessage: some View {
        Text(
            "+ 버튼을 눌러 빠른 말하기를 추가해보세요"
        )
        .typography(.bodyMedium)
        .foregroundStyle(.textmuted)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.top, 72)
        .allowsHitTesting(false)
    }
}

// MARK: - Navigation Actions

private extension FastSpeechView {

    func handleLeftTap() {
        if viewModel.isEditing {
            withAnimation(.snappy) {
                viewModel.cancelEditing()
            }
        } else {
            dismiss()
        }
    }

    func handleRightTap() {
        if viewModel.isEditing {
            withAnimation(.snappy) {
                viewModel.deleteSelectedPhrases(
                    phrases: phrases,
                    modelContext: modelContext
                )
            }
        } else {
            withAnimation(.snappy) {
                viewModel.startEditing()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FastSpeechView()
    }
    .modelContainer(
        for: [
            FastSpeechCategory.self,
            FastSpeechPhrase.self
        ],
        inMemory: true
    )
    .environment(
        \.locale,
        Locale(identifier: "ko")
    )
}
