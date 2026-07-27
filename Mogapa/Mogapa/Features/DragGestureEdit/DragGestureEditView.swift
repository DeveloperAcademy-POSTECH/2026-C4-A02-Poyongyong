//
//  DragGestureEditView.swift
//  Mogapa
//
//  Created by sun on 7/23/26.
//

import SwiftData
import SwiftUI

@MainActor
struct DragGestureEditView: View {

    // MARK: - Environment

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var modelContext

    // MARK: - State

    @State
    private var viewModel: DragGestureEditViewModel

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
        SpeechListView(
            title: "드래그 제스처",
            isEditing: viewModel.isEditing,
            hasSelection:
                !viewModel.selectedIDs.isEmpty,
            createButtonBottomPadding: 15,
            onBack: {
                dismiss()
            },
            onCancelEditing: {
                viewModel.cancelEditing()
            },
            onStartEditing: {
                viewModel.beginEditing()
            },
            onDeleteSelected: {
                withAnimation(
                    .snappy
                ) {
                    viewModel.deleteSelectedGestures()
                }
            },
            onCreate: {
                viewModel.presentAddModal()
            }
        ) {
            gestureList
        }
        .task {
            viewModel.load(
                modelContext: modelContext
            )
        }
        .sheet(
            item: Binding(
                get: {
                    viewModel.presentedModal
                },
                set: {
                    viewModel.presentedModal = $0
                }
            )
        ) { modal in
            modalContent(
                modal
            )
        }
    }
}

// MARK: - Gesture List

private extension DragGestureEditView {

    var gestureList: some View {
        QuickSpeechBubbleList(
            items:
                viewModel.bubbleItems,
            isEditing:
                viewModel.isEditing,
            allowsMove:
                true,
            allowsFullSwipeDelete:
                true,
            selectedIDs:
                Binding(
                    get: {
                        viewModel.selectedIDs
                    },
                    set: {
                        viewModel.selectedIDs = $0
                    }
                ),
            onTap: { id in
                viewModel.presentEditModal(
                    gestureID: id
                )
            },
            onDelete: { id in
                withAnimation(
                    .snappy
                ) {
                    viewModel.deleteGesture(
                        id: id
                    )
                }
            },
            onMove: { source, destination in
                withAnimation(
                    .snappy
                ) {
                    viewModel.moveGestures(
                        from: source,
                        to: destination
                    )
                }
            }
        )
        .padding(
            .horizontal,
            20
        )
    }
}

// MARK: - Modal

private extension DragGestureEditView {

    @ViewBuilder
    func modalContent(
        _ modal: DragGestureEditModal
    ) -> some View {
        GestureModalContent(
            title: modal.title,
            onSaved: {
                viewModel.load(
                    modelContext: modelContext
                )
            }
        )
    }
}
