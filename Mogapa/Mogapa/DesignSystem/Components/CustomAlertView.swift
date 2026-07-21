//
//  CustomAlertView.swift
//  Mogapa
//
//  Created by Minjae Son on 7/22/26.
//

import SwiftUI

struct CustomAlertView: View {
    
    let title: String
    let message: String
    
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        
        VStack(alignment:.leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
                .padding(.bottom,10)
                .padding(.horizontal, 8)
            
            Text(message)
                .font(.body)
                .foregroundColor(.black)
                .padding(.bottom, 24)
                .padding(.horizontal, 8)
            
            VStack {
                VStack {
                    Button {
                        onCancel()
                    } label: {
                        Text("삭제")
                            .frame(maxWidth: .infinity, minHeight: 36
                            )
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .foregroundColor(.white)
                    .padding(.bottom, 2)
                    
                    Button {
                        onConfirm()
                    } label: {
                        Text("취소")
                            .frame(maxWidth: .infinity, minHeight: 36
                            )
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.gray.opacity(0.3))
                    .foregroundColor(.black)
                }
            }
        }
        .padding(14)
        .padding(.top, 8)
        .background(Color.white.opacity(0.7))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 28)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    Color.gray.opacity(0.3),
                    lineWidth: 1
                )
        )
        .shadow(radius: 20)
        .padding(.horizontal, 54)
    }
}

#Preview {
    @Previewable @State var isPresented = true
    
    Color.gray
        .customAlert(
            isPresented: $isPresented,
            title: "카테고리를 삭제하시겠습니까?",
            message: "카테고리 내 문구들도 한번에 지워집니다.",
            onConfirm: {
                print("Confirmed")
            }
        )
}
