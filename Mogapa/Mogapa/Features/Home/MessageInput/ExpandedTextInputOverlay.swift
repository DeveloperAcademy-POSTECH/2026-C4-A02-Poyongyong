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
                    .padding(.top, geometry.size.height * 0.14)
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
                focusTextEditor()
            }
        }
    }
}


// MARK: - Expanded Text Field

private extension ExpandedTextInputOverlay {
    
    var expandedTextField:
    some View {
        
        VStack(alignment: .leading) {
            
            
            // MARK: - Landscape Instruction
            
            HStack(spacing: 8) {
                Image(systemName:"rectangle.portrait.rotate")
                .font(.system(size:16))
                .foregroundColor(.iconmuted)
                
                Text("가로로 돌려 표현하기")
                    .typography(.calloutRegular)
                    .foregroundStyle(.textmuted)
                
                Spacer()
            }
            
            
            // MARK: - Divider
        
            Divider()
            
            
            // MARK: - Text Editor
            
            TextEditor(
                text: $text
            )
            .scrollDisabled(true)
            .focused($isTextEditorFocused)
            .scrollContentBackground(.hidden)
            .typography(.subTitleMedium)
            .foregroundColor(.textprimary)
            .multilineTextAlignment(.leading)
            .frame(
                maxWidth:.infinity,
                maxHeight:.infinity
            )
            
            .onChange(
                of:text
            ) { _, newValue in
                onTextChanged(
                    newValue
                )
            }
            
            
            // MARK: - Bottom Controls
            
            HStack {
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
        .padding(.bottom,22)
        .frame(width:362, height:329)
        .background(Color.backgroundbgCanvas)
        
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius:40,
                bottomTrailingRadius:40,
                topTrailingRadius:40,
                style:.continuous
            )
        )
        .shadow(
            color:.black.opacity(0.15),
            radius:12,
            x:0,
            y:6
        )
    }
}


// MARK: - Speak Button

private extension ExpandedTextInputOverlay {
    
    var speakButton:
    some View {
        
        Button {
            guard !text.isEmpty else {
                return
            }
            onSpeak()
        } label: {
            Image(systemName: "waveform")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame( width: 40, height: 40)
                .background(
                    text.isEmpty ? Color.iconmuted : Color(.labelprimary))
                .clipShape(
                    Circle()
                )
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

