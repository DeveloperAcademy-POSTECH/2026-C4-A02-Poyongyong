//
//  CategoryPicker.swift
//  Mogapa
//
//  Created by JENNA on 7/21/26.
//

import SwiftUI

struct CategoryPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selected: String
    let categories: [String]

    var body: some View {
        VStack(spacing: 0) {
            ModalHeader(
                title: "카테고리 선택",
                onClose: { dismiss() },
                onConfirm: { dismiss() }
            )
            .padding(.top, 22)
            .padding(.horizontal, 6)
            
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.backgroundbgDisabled))
        .presentationDetents([.height(725)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(38)
    }
    
    private var content: some View {
            VStack(spacing: 0) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        selected = category
                    } label: {
                        HStack {
                            Text(category)
                                .foregroundStyle(.textprimary)
                            Spacer()
                            if category == selected {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if category != categories.last {
                        Divider().padding(.horizontal, 24)
                    }
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.backgroundbgCanvas)
            }
            .padding(.top, 24)
            .padding(.horizontal, 16)
        }
    }

