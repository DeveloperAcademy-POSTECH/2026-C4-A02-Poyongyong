//
//  ExpandedTextInputOverlay.swift
//  Mogapa
//
//  Created by Minjae Son on 7/21/26.
//

import SwiftUI
import ImageIO


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
                GifImageView(
                    "RotateLandscapeHint",
                    isAnimating: !text.isEmpty
                )
                .frame(
                    width: 18,
                    height: 18
                )
                .scaleEffect(0.1)
                .accessibilityHidden(true)
                
                Text("가로로 돌려 표현하기")
                    .typography(.calloutRegular)
                    .foregroundStyle(.textmuted)
                
                Spacer()
            }
            
            Divider()
            
        
            ZStack(alignment: .topLeading) {
                
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
                
                if text.isEmpty {
                    Text("무엇을 이야기하고 싶은가요?")
                        .typography(.subTitleMedium)
                        .foregroundColor(.textplaceholder)
                        .padding(
                            .top,
                            8
                        )
                        .padding(
                            .leading,
                            5
                        )
                        .allowsHitTesting(false)
                }
            }
            .frame(
                maxWidth: .infinity
            )
            .frame(
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
            maxWidth: .infinity
        )
        .frame(
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
        .padding(.horizontal, 20)
    }
}


// MARK: - GIF Image View

private struct GifImageView: UIViewRepresentable {
    
    private static let animationDuration = 3.3
    
    let gifName: String
    
    let isAnimating: Bool
    
    init(
        _ gifName: String,
        isAnimating: Bool
    ) {
        self.gifName = gifName
        self.isAnimating = isAnimating
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        
        guard let asset = NSDataAsset(name: gifName),
              let source = CGImageSourceCreateWithData(
                asset.data as CFData,
                nil
              ) else {
            return imageView
        }
        
        let frameCount = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        
        for index in 0..<frameCount {
            guard let cgImage = CGImageSourceCreateImageAtIndex(
                source,
                index,
                nil
            ) else {
                continue
            }
            
            images.append(
                UIImage(cgImage: cgImage)
            )
        }
        
        imageView.image = images.first
        imageView.animationImages = images
        imageView.animationDuration = Self.animationDuration
        imageView.animationRepeatCount = 0
        
        updateAnimation(
            for: imageView,
            coordinator: context.coordinator
        )
        
        return imageView
    }
    
    func updateUIView(
        _ uiView: UIImageView,
        context: Context
    ) {
        updateAnimation(
            for: uiView,
            coordinator: context.coordinator
        )
    }
    
    private func updateAnimation(
        for imageView: UIImageView,
        coordinator: Coordinator
    ) {
        if isAnimating {
            coordinator.playForever(
                imageView: imageView,
                animationDuration: Self.animationDuration
            )
        } else {
            coordinator.stopAfterCurrentLoop(
                imageView: imageView,
                animationDuration: Self.animationDuration
            )
        }
    }
    
    final class Coordinator {
        
        private var pendingStopTimer: Timer?
        
        func playForever(
            imageView: UIImageView,
            animationDuration: Double
        ) {
            pendingStopTimer?.invalidate()
            pendingStopTimer = nil
            
            guard !imageView.isAnimating else {
                return
            }
            
            imageView.animationDuration = animationDuration
            imageView.animationRepeatCount = 0
            imageView.startAnimating()
        }
        
        func stopAfterCurrentLoop(
            imageView: UIImageView,
            animationDuration: Double
        ) {
            guard imageView.isAnimating else {
                imageView.image = imageView.animationImages?.first
                return
            }
            
            guard pendingStopTimer == nil else {
                return
            }
            
            pendingStopTimer = Timer.scheduledTimer(
                withTimeInterval: animationDuration,
                repeats: false
            ) { [weak self, weak imageView] _ in
                guard let self,
                      let imageView else {
                    return
                }
                
                self.pendingStopTimer = nil
                imageView.stopAnimating()
                imageView.image = imageView.animationImages?.first
            }
        }
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
    .environment(\.locale,Locale(identifier: "ko")
    )

}
