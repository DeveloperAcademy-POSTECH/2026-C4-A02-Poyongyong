//
//  DragGestureView.swift
//  Mogapa
//
//  Created by Sue on 7/21/26.
//

import SwiftData
import SwiftUI

struct DragGestureView: View {

    @Environment(\.dismiss) private var dismiss

    @Query(sort: \RegisteredDragGesture.createdAt)
    private var registeredGestures: [RegisteredDragGesture]

    @State private var viewModel =
        DragGestureViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(
            alignment: .leading,
            spacing: 32
        ) {
            DragHeader {
                viewModel.showEditView()
            }

            VStack(
                alignment: .leading,
                spacing: 24
            ) {
                DragIndicator(
                    title: viewModel.recognizedTitle,
                    state: viewModel.dragState
                )

                DragCanvas(
                    dragPoints: Binding(
                        get: {
                            viewModel.currentPoints
                        },
                        set: {
                            viewModel.updateCurrentPoints($0)
                        }
                    )
                ) { finishedPoints in
                    viewModel.recognize(
                        finishedPoints,
                        registeredGestures:
                            registeredGestures,
                        dismiss: {
                            dismiss()
                        }
                    )
                }
            }
        }
        .padding(.top, 32)
        .padding(.bottom, 25)
        .padding(
            [.leading, .trailing],
            20
        )
        .background(dimBackground)
        .overlay(
            alignment: .bottomTrailing
        ) {
            homeButton
        }
        .navigationDestination(
            isPresented:
                $viewModel.isShowingEditView
        ) {
            DragGestureEditView(
                viewModel:
                    DragGestureEditViewModel()
            )
            .swipeBackEnabled(true)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 0.25)
            ) {
                viewModel.appear()
            }
        }
        .onDisappear {
            viewModel.disappear()
        }
    }
}

// MARK: - UI

private extension DragGestureView {

    var dimBackground: some View {
        Color.black
            .opacity(
                viewModel.isDimmed ? 0.8 : 0
            )
            .ignoresSafeArea()
    }

    var homeButton: some View {
        CreateButton(
            systemImage:
                "arrow.down.right.and.arrow.up.left",
            showsTint: false
        ) {
            viewModel.dismissImmediately {
                dismiss()
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .bottomTrailing
        )
        .padding(.trailing, 20)
        .padding(.bottom, 15)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DragGestureView()
    }
}
