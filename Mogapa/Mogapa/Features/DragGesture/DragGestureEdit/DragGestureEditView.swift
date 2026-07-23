//
//  DragGestureEditView.swift
//  Mogapa
//
//  Created by sun on 7/23/26.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@MainActor
struct DragGestureEditView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    @Environment(\.modelContext) private var modelContext


    // MARK: - State

    @State private var viewModel: DragGestureEditViewModel
    @State private var openedRowID: UUID?


    // MARK: - Initializer

    init() {
        _viewModel = State(
            initialValue:
                DragGestureEditViewModel()
        )
    }

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
            VStack(spacing: 18) {
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
                .padding(.trailing, 31)
                .padding(.bottom, 8)
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
            onLeftTap:
                handleLeftTap,
            onRightTap:
                handleRightTap
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
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
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
            isSelected:
                viewModel.isSelected(
                    gesture.id
                ), isEditing: viewModel.isEditing,
            openedRowID:
                $openedRowID,
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
                // 드래그 제스처에서는 고정 기능 사용안해서 nil 입니닷
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
            viewModel.draggingID ==
                gesture.id
            ? 0.55
            : 1
        )
        .contentShape(
            Rectangle()
        )
        .onDrag {
            guard !viewModel.isEditing else {
                return NSItemProvider()
            }

            openedRowID = nil

            viewModel.beginDragging(
                gesture.id
            )

            return NSItemProvider(
                object:
                    gesture.id.uuidString
                    as NSString
            )
        }
        .onDrop(
            of: [
                UTType.text.identifier
            ],
            delegate:
                DragGestureReorderDropDelegate(
                    destinationID:
                        gesture.id,
                    viewModel:
                        viewModel
                )
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
                viewModel
                    .deleteSelectedGestures()
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

// MARK: - Drop Delegate

@MainActor
private struct DragGestureReorderDropDelegate:
    DropDelegate {

    let destinationID: UUID

    let viewModel:
        DragGestureEditViewModel

    func dropEntered(
        info: DropInfo
    ) {
        guard !viewModel.isEditing else {
            return
        }

        withAnimation(
            .snappy
        ) {
            viewModel
                .moveDraggingGesture(
                    before: destinationID
                )
        }
    }

    func performDrop(
        info: DropInfo
    ) -> Bool {
        viewModel.finishDragging()

        return true
    }

    func dropUpdated(
        info: DropInfo
    ) -> DropProposal? {
        DropProposal(
            operation: .move
        )
    }

    func dropExited(
        info: DropInfo
    ) {
        // 다른 Row로 이동하는 중에도
        // draggingID를 유지해야 하므로 비워둡니다.
    }
}


// MARK: - Preview

@MainActor
private struct DragGestureEditPreview:
    View {

    @State
    private var viewModel:
        DragGestureEditViewModel

    init() {
        _viewModel = State(
            initialValue:
                DragGestureEditViewModel(
                    gestures:
                        DragGestureEditDummyData
                            .make()
                )
        )
    }

    var body: some View {
        NavigationStack {
            DragGestureEditView(
                viewModel: viewModel
            )
        }
    }
}

#Preview {
    DragGestureEditPreview()
        .modelContainer(
            for:
                RegisteredDragGesture.self,
            inMemory: true
        )
        .environment(
            \.locale,
            Locale(
                identifier: "ko"
            )
        )
}
