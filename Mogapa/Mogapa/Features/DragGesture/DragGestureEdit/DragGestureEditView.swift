//
//  DragGestureEditView.swift
//  Mogapa
//
//  Created by sun on 7/23/26.
//

import SwiftUI
import SwiftData

@MainActor
struct DragGestureEditView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext


    // MARK: - State

    @State private var viewModel: DragGestureEditViewModel
    @State private var openedRowID: UUID?
    @State private var draggingID: UUID?


    // MARK: - Initializer

    init(
        viewModel: DragGestureEditViewModel
    ) {
        _viewModel = State(
            initialValue: viewModel
        )
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

                gestureList
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
                .padding(
                    .trailing,
                    31
                )
                .padding(
                    .bottom,
                    8
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
        .task {
            viewModel.load(
                modelContext: modelContext
            )
        }
        .sheet(
            item: $viewModel.presentedModal
        ) { modal in
            modalContent(
                modal
            )
        }
    }
}


// MARK: - Header

private extension DragGestureEditView {

    var header: some View {
        MogapaNavigationHeader(
            title: "드래그 제스처",
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
            rightTint:
                viewModel.isEditing
                ? .accentsRed
                : .clear,
            rightForegroundStyle:
                viewModel.isEditing
                ? .iconinverse
                : .textsecondary,
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
}


// MARK: - List

private extension DragGestureEditView {

    var gestureList: some View {
        ScrollView {
            LazyVStack(
                spacing: 12
            ) {
                ForEach(
                    viewModel.gestures,
                    id: \.id
                ) { gesture in
                    gestureRow(
                        gesture
                    )
                }
            }
            .padding(
                .horizontal,
                20
            )
            .padding(
                .bottom,
                100
            )
        }
        .scrollIndicators(
            .hidden
        )
    }

    func gestureRow(
        _ gesture: RegisteredDragGesture
    ) -> some View {
        QuickSpeechBubbleRow(
            id: gesture.id,
            text: gesture.phrase,
            isPinned: false,
            isSelected: viewModel.isSelected(
                gesture.id
            ),
            isEditing: viewModel.isEditing,
            openedRowID: $openedRowID,
            onTap: {
                withAnimation(
                    .snappy
                ) {
                    viewModel.handleItemTap(
                        gesture
                    )
                }
            },
            onSelectionToggle: {
                withAnimation(
                    .snappy
                ) {
                    viewModel.toggleSelection(
                        gesture.id
                    )
                }
            },
            onPin: {
                openedRowID = nil
            },
            onUnpin: {
                openedRowID = nil
            },
            onDelete: {
                withAnimation(
                    .snappy
                ) {
                    openedRowID = nil

                    viewModel.deleteGesture(
                        gesture
                    )
                }
            }
        )
        .opacity(
            draggingID == gesture.id
            ? 0.55
            : 1
        )
        .dragDrop(
            isEditing: !viewModel.isEditing,
            itemID: gesture.id,
            draggedItemID: $draggingID,
            onMove: { sourceID, destinationID in
                openedRowID = nil

                viewModel.moveGesture(
                    sourceID: sourceID,
                    destinationID: destinationID
                )
            }
        )
    }
}


// MARK: - Header Actions

private extension DragGestureEditView {

    func handleLeftTap() {
        if viewModel.isEditing {
            withAnimation(
                .snappy
            ) {
                viewModel.cancelEditing()
            }

            return
        }

        dismiss()
    }

    func handleRightTap() {
        withAnimation(
            .snappy
        ) {
            if viewModel.isEditing {
                viewModel.deleteSelectedGestures()
            } else {
                viewModel.beginEditing()
            }
        }
    }
}


// MARK: - Modal

private extension DragGestureEditView {

    @ViewBuilder
    func modalContent(
        _ modal: DragGestureEditModal
    ) -> some View {
        GestureModalContent(
            title: modal.title
        )
    }
}
