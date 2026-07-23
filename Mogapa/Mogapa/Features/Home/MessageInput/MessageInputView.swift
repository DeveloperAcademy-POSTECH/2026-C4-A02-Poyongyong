//
//  MessageInputView.swift
//  Mogapa
//
//  Created by Minjae Son on 7/21/26.
//

import SwiftUI

struct MessageInputView: View {
    
    // MARK: - Input
    
    @Binding
    var text: String
    
    @Binding
    var isExpanded: Bool
    
    // MARK: - Character Count
    
    let characterCount: Int
    
    
    // MARK: - Actions
    
    let onTextChanged: (String) -> Void
    
    let onSpeak:() -> Void
    
    
    // MARK: - Keyboard Focus
    
    @FocusState
    private var isFocused: Bool
    
    
    // MARK: - Body
    
    var body: some View {
        
        ZStack {
            
            // MARK: - Collapsed State
            
            if !isExpanded {
                collapsedInput
                    .transition(.scale(scale:0.95)
                        .combined(with:.opacity))
                    .onTapGesture {expandInput()
                    }
            }
            
            // MARK: - Expanded State
            
            if isExpanded {
                expandedOverlay
                    .transition(.opacity)
            }
        }
    }
}


// MARK: - Collapsed Input

private extension MessageInputView {
    
    var collapsedInput:
    some View {
        VStack(alignment: .leading) {
            
            // MARK: - Placeholder
            
            if text.isEmpty {
                   Text("무엇을 이야기하고 싶은가요?")
                       .typography(.subTitleMedium)
                       .foregroundColor(.textplaceholder)
               } else {
                   Text(text)
                       .typography(.subTitleMedium)
                       .foregroundColor(.textprimary)
                       .multilineTextAlignment(.leading)
               }
            
            Spacer()
            
            // MARK: - Bottom Controls
            
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
            height: 204
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
        .shadow(
            color: .black.opacity(0.08),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}


// MARK: - Expanded Overlay

private extension MessageInputView {
    
    var expandedOverlay:
    some View {
        
        ZStack(alignment:.top
        ) {
            // MARK: - Dark Background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    closeInput()
                }
            
            // MARK: - Expanded Text Field
            expandedInput
                .padding(.top,116)
        }
        .frame(maxWidth:.infinity,
               maxHeight:.infinity
        )
        .ignoresSafeArea(
            .keyboard,
            edges:.bottom
        )
        .onAppear {
            focusTextEditor()
        }
    }
}


// MARK: - Expanded Input

private extension MessageInputView {
    
    var expandedInput:
    some View {
        
        VStack(alignment:.leading, spacing:8)
        {
            
            // MARK: - Landscape Instruction
            HStack(spacing:8) {
                Image(systemName:"rectangle.portrait.rotate")
                    .font(.system(size:16))
                Text("가로로 돌려 표현하기")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                Spacer()
            }
            
            
            // MARK: - Divider
            
            Divider()
            
            
            // MARK: - Text Editor
            
            TextEditor(text: $text)
                .focused($isFocused)
                .scrollContentBackground(.hidden)
                .font(.system(size:16))
                .onChange(
                    of:text
                ) { _, newValue in
                    onTextChanged(newValue)
                }
            
            // MARK: - Bottom Controls
            
            HStack(alignment:.bottom){
                Text("\(characterCount)/150")
                    .typography(.calloutRegular)
                    .foregroundColor(.texttertiary)
                
                Spacer()
                
                speakButton
            }
        }
        .padding(16)
        .frame(width:362,height:329)
        .background(Color.backgroundbgCanvas)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius:0,
                bottomLeadingRadius:40,
                bottomTrailingRadius:40,
                topTrailingRadius:40,
                style:.continuous
            )
        )
        .shadow(color:.black.opacity(0.15),
                radius:12,
                x:0,
                y:6
        )
    }
}


// MARK: - Speak Button

private extension MessageInputView {
    
    var speakButton:
    some View {
        
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

private extension MessageInputView {
    
    func expandInput() {
        withAnimation(
            .spring(
                response:0.35,
                dampingFraction:0.8
            )
        ) {isExpanded = true
        }
    }
    
    func closeInput() {
        withAnimation(
            .spring(response: 0.35,
                    dampingFraction:0.8
                   )
        ) {
            isFocused = false
            isExpanded = false
        }
    }
    
    func focusTextEditor() {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.25)
        { isFocused = true
        }
    }
}


// MARK: - Preview

#Preview {
    MessageInputView(
        text:.constant("안녕하세요. 미리보기 텍스트입니다."),
        isExpanded:.constant(false),
        characterCount:19,
        onTextChanged: { text in
            print(text)
        },
        onSpeak: {
            print("Speak")
        }
    )
    .padding()
}
