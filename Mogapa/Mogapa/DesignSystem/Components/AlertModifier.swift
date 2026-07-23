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
                    Color.gray.opacity(0.2)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isPresented = false
                        }
                    CustomAlertView(
                        title: title,
                        message: message,
                        onConfirm: {
                            onConfirm()
                            isPresented = false
                        },
                        onCancel: {
                            isPresented = false
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1)
                }
            }
        }
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
