//
//  HomeView.swift
//  Mogapa
//
//  Created by Minjae Son on 7/21/26.
//

import SwiftUI
import SwiftData


struct HomeView: View {
    
    // MARK: - SwiftData
    @Environment(\.modelContext) private var modelContext
    
    @Query(
        sort: [
            SortDescriptor(
                \FastSpeechCategory.sortOrder,
                 order: .forward
            )
        ]
    )
    private var categories:
    [FastSpeechCategory]
    
    // TODO: fast speech 연결 확인 후 다시 활성화
//    @Query(
//        filter: #Predicate<FastSpeechPhrase> { $0.category == nil },
//        sort: [SortDescriptor(\FastSpeechPhrase.createdAt, order: .reverse)]
//    )
//    private var recentPhrases: [FastSpeechPhrase]
//    
    // MARK: - TestViews
    
    @State private var isSpeechTestPresented = false
    @State private var isFastSpeechListPresented = false
    @State private var isSettingsPresented = false
    @State private var isPresentationPresented = false
    @State private var isGesturePresented = false
    
    
    // MARK: - CoreMotion, 화면방향
    
    @StateObject private var motionManager = CoreMotionManager()
    @State private var presentationOrientation: UIInterfaceOrientationMask = .landscapeRight
    
    
    // MARK: - ViewModel
    
    @StateObject
    private var viewModel =
    HomeViewModel()
    
    
    // MARK: - Body
    
    var body: some View {
        
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    
                    // MARK: - Background Layers
                    
                    VStack {
                        Rectangle()
                            .fill(Color(.backgroundbgDefault))
                            .ignoresSafeArea(edges: .top)
                            .frame(width: geometry.size.width, height: 320)
                        Rectangle()
                            .fill(Color(.backgroundbgCanvas))
                    }
                    
                    
                    // MARK: - Main Home Content
                    
                    VStack{
                        header
                        
                        titleSection
                        
                        messageInput
                        
                        fastSpeechSection
                    }
                    .padding(.horizontal,20)
                    .frame(
                        width: geometry.size.width)
                    
                    
                    // MARK: - Expanded Text Input Overlay
                    
                    if viewModel.isTextFieldExpanded {
                        ExpandedTextInputOverlay(
                            text:$viewModel.inputText,
                            characterCount:viewModel.characterCount,
                            onTextChanged: { text in
                                viewModel.updateText(text)
                            },
                            onSpeak: {
                                presentIfPossible(orientation: orientationMask(for: motionManager.pose))
                            },
                            onClose: {
                                viewModel.isTextFieldExpanded = false
                            }
                        )
                    }
                }
            }.navigationDestination(isPresented: $isSpeechTestPresented) {
                SpeechTestView(text: viewModel.inputText)
            }
            .navigationDestination(isPresented: $isFastSpeechListPresented) {
                FastSpeechListTestView()
            }
            .navigationDestination(isPresented: $isSettingsPresented) {
                SettingView()
                    .toolbar(.hidden, for: .navigationBar)
            }
            .onAppear {
                motionManager.start()
                AppDelegate.lock(to: .portrait)
            }
            .onDisappear {
                motionManager.stop()
            }
            .onChange(of: motionManager.pose) { _, pose in
                guard pose.isLandscape else {
                    isPresentationPresented = false
                    return
                }
                presentIfPossible(orientation: orientationMask(for: pose))
            }
            .onChange(of: isPresentationPresented) { wasPresented, isPresented in
                guard wasPresented, !isPresented else { return }
                saveToRecentAndReset()
            }
            .fullScreenCover(isPresented: $isPresentationPresented) {
                PresentationView(text: viewModel.inputText, orientation: presentationOrientation)
            }
             .sheet(isPresented: $isGesturePresented) {
                        MotionGestureTestView()  // 여기 제스처 뷰 넣으셈!!!!
                    }
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Header

private extension HomeView {
    
    var header:
    some View {
        
        HStack {
            Image("AppIconImage")
                .resizable()
                .frame(width:50,height:34)
            
            Spacer()
            
            BasicButton(
                systemImage: "gearshape.fill",
                shape: .circle,
                foregroundStyle: .white,
                font: .system(size: 24)
            ) {
                isSettingsPresented = true
            }
        }
        .padding(.top, 10)
    }
}


// MARK: - Title Section

private extension HomeView {
    
    var titleSection:
    some View {
        
        HStack{
            Text("말하기를\n시작해 볼까요?")
                .typography(.largeTitleBold)
                .foregroundColor(.textwhite)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            VStack(alignment:.trailing, spacing: 4
            ) {
                Image(systemName:"rectangle.portrait.rotate")
                    .font(.system(size:28))
                    .foregroundColor(.iconinverse)
                Text("가로로 돌려\n표현하기")
                    .typography(.bodyMedium)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal:false, vertical:true)
                    .foregroundColor(.textwhite)
            }
        }
    }
}


// MARK: - Normal Message Input

private extension HomeView {
    
    var messageInput:
    some View {
        
        MessageInputView(
            text: $viewModel.inputText,
            isExpanded: $viewModel.isTextFieldExpanded,
            characterCount: viewModel.characterCount,
            onTextChanged: { text in
                viewModel.updateText(text)
            },
            onSpeak: {
                presentIfPossible(orientation: orientationMask(for: motionManager.pose))
            },
        )
        .frame(width: 362,height: 204)
        .frame(maxWidth: .infinity)
        .padding(.bottom, 16)
        .opacity(
            viewModel.isTextFieldExpanded ? 0 : 1
        )
    }
}


// MARK: - Fast Speech Section

private extension HomeView {
    
    var fastSpeechSection:
    some View {
        
        FastSpeechSection(
            categories:
                categories,
            
            recentPhrases:
                [], // TODO: recentPhrases 연결 후 교체
            
            selectedCategoryIndex:
                $viewModel.selectedCategoryIndex,
            
            selectedPhraseID:
                viewModel.selectedPhraseID,
            
            previewText: { text in
                viewModel.previewText(
                    for: text)
            },
            onPhraseSelected: { phrase in
                viewModel.selectPhrase(phrase)
            },
            onShowAllFastSpeech: {
                isFastSpeechListPresented =
                true
            }
        )
        .frame(maxWidth:.infinity)
        .padding(.bottom, 20)
    }
}

// MARK: - Speech Button or Rotation

private extension HomeView {
    func presentIfPossible(orientation: UIInterfaceOrientationMask) {
        let hasContent = !viewModel.inputText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty

        guard hasContent else { return }

        viewModel.isTextFieldExpanded = false

        AppDelegate.orientationLock = orientation
        presentationOrientation = orientation
        isPresentationPresented = true
    }
}

// MARK: - Orientation 매핑

private extension HomeView {
    func orientationMask(for pose: MotionPose) -> UIInterfaceOrientationMask {
        switch pose {
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return .landscapeRight
        }
    }
}

// MARK: - 최근 저장 & 리셋

private extension HomeView {
    func saveToRecentAndReset() {
        let text = viewModel.inputText
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !text.isEmpty else { return }
        
        // TODO: fast speech 연결 확인 후 다시 활성화
//        let phrase = FastSpeechPhrase(text: text)
//
//        do {
//            try FastSpeechRepository(modelContext: modelContext)
//                .insertPhrase(phrase)
//        } catch {
//            print("최근 문구 저장 실패: \(error)")
//        }

        viewModel.updateText("")
    }
}

#Preview {
    HomeView()
}
