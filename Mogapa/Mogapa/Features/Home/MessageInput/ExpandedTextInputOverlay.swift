//
//  ExpandedTextInputOverlay.swift
//  Mogapa
//
//  Created by Minjae Son on 7/21/26.
//

import SwiftUI


struct ExpandedTextInputOverlay: View {
    
    // MARK: - Data
    
    @Binding
    var text: String
    
    let characterCount: Int
    
    
    // MARK: - Actions
    
    let onTextChanged: (String) -> Void
    
    let onSpeak: () -> Void
    
    let onClose: () -> Void
    
    
    @FocusState
    private var isTextEditorFocused: Bool
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                
                // MARK: - Dark Background
                
                Color.black
                    .opacity(0.55)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        closeOverlay()
                    }
                
                
                // MARK: - Expanded Text Field
                
                expandedTextField
                    .padding(
                        .top,
                        geometry.size.height * 0.08
                    )
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .ignoresSafeArea(
                .keyboard, edges: .bottom
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 0.3
                ) {
                    isTextEditorFocused = true
                }
            }
        }
    }
}


// MARK: - Expanded Text Field

private extension ExpandedTextInputOverlay {
    
    var expandedTextField: some View {
        
        VStack(alignment: .leading) {
            
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.rotate")
                    .font(.system(size: 16))
                    .foregroundColor(.iconmuted)
                
                Text("가로로 돌려 표현하기")
                    .typography(.calloutRegular)
                    .foregroundStyle(.textmuted)
                
                Spacer()
            }
            
            Divider()
            
        
            ZStack(alignment: .topLeading) {
                
                if text.isEmpty {
                    Text("무엇을 이야기하고 싶은가요?")
                        .typography(.subTitleMedium)
                        .foregroundColor(.textplaceholder)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .allowsHitTesting(false)
                }
                
                TextEditor(
                    text: $text
                )
                .tint(.labelprimary)
                .scrollDisabled(true)
                .focused($isTextEditorFocused)
                .scrollContentBackground(.hidden)
                .typography(.subTitleMedium)
                .foregroundColor(.textprimary)
                .multilineTextAlignment(.leading)
                .onChange(
                    of: text
                ) { _, newValue in
                    onTextChanged(newValue)
                }
            }
            .frame(
                width: 312,
                height: 240
            )
         
            HStack(alignment: .bottom) {
                Text("\(characterCount)/150")
                    .typography(.calloutRegular)
                    .foregroundColor(.texttertiary)
                
                Spacer()
                
                speakButton
            }
        }
        .padding(.leading, 32)
        .padding(.trailing, 18)
        .padding(.top, 25)
        .padding(.bottom, 22)
        .frame(
            width: 362,
            height: 365
        )
        .background(Color.backgroundbgCanvas)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 40,
                bottomTrailingRadius: 40,
                topTrailingRadius: 40,
                style: .continuous
            )
        )
    }
}


// MARK: - Speak Button

private extension ExpandedTextInputOverlay {
    
    var speakButton: some View {
        
        Button {
            guard !text.isEmpty else {
                return
            }
            onSpeak()
        } label: {
            Image(systemName:"waveform")
                .font(.system(size:20,weight:.semibold))
                .foregroundColor(text.isEmpty ? Color(.iconmuted) : Color(.textwhite))
                .frame(width:40,height:40)
                .background(
                    text.isEmpty ? Color(.backgroundbgDisabled) : Color(.labelprimary)
                )
                .clipShape(Circle())
        }
        .disabled(text.isEmpty)
    }
}


// MARK: - Actions

private extension ExpandedTextInputOverlay {
    
    func focusTextEditor() {
        DispatchQueue.main.asyncAfter( deadline:
                .now() + 0.25
        ) {
            isTextEditorFocused = true
        }
    }
    
    func closeOverlay() {
        isTextEditorFocused = false
        onClose()
    }
}


// MARK: - Preview

#Preview {
    
    ExpandedTextInputOverlay(
        
        text: .constant("안녕하세요. 미리보기 텍스트입니다."),
        characterCount: 19,
        onTextChanged: { text in
            print(text)
        },
        onSpeak: {
            print("Speak")
        },
        onClose: {
            print("Close")
        }
    )
}

