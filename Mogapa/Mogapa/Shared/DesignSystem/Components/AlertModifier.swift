//
//  AlertModifier.swift
//  Mogapa
//
//  Created by Minjae Son on 7/22/26.
//

import SwiftUI

struct AlertModifier: ViewModifier {
    
    @Binding var isPresented: Bool
    
    let title: String
    let message: String
    let onConfirm: () -> Void
    
    func body(content: Content) -> some View {
        
        ZStack {
            content
            if isPresented {
                ZStack {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.snappy(duration: 0.22)) {
                                isPresented = false
                            }
                        }
                    CustomAlertView(
                        title: title,
                        message: message,
                        onConfirm: {
                            onConfirm()
                            withAnimation(.snappy(duration: 0.22)) {
                                isPresented = false
                            }
                        },
                        onCancel: {
                            withAnimation(.snappy(duration: 0.22)) {
                                isPresented = false
                            }
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1)
                }
                .transition(.opacity)
            }
        }
        .animation(
            .snappy(duration: 0.22),
            value: isPresented
        )
    }
}

extension View {
    
    func customAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        onConfirm: @escaping () -> Void
    ) -> some View {
        
        modifier(
            AlertModifier(
                isPresented: isPresented,
                title: title,
                message: message,
                onConfirm: onConfirm
            )
        )
    }
}
