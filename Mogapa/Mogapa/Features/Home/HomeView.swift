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
    
    @Environment(\.modelContext)
    private var modelContext
    
    @Query(
        sort: [
            SortDescriptor(
                \FastSpeechCategory.sortOrder,
                 order: .forward
            )
        ]
    )
    private var categories: [FastSpeechCategory]
    
    // category가 nil인 문구는 최근 사용 문구
    @Query(
        filter: #Predicate<FastSpeechPhrase> { phrase in
            phrase.category == nil
        },
        sort: [
            SortDescriptor(
                \FastSpeechPhrase.createdAt,
                 order: .reverse
            )
        ]
    )
    private var recentPhrases: [FastSpeechPhrase]
    
    
    // MARK: - Navigation
    
    @State
    private var isSpeechTestPresented = false
    
    @State
    private var isFastSpeechListPresented = false
    
    @State
    private var isSettingsPresented = false
    
    @State
    private var isPresentationPresented = false
    
    @State
    private var isGesturePresented = false
    
    
    // MARK: - CoreMotion, 화면 방향
    
    @StateObject
    private var motionManager = CoreMotionManager()
    
    @State
    private var presentationOrientation:
    UIInterfaceOrientationMask = .landscapeRight
    
    
    // MARK: - ViewModel
    
    @StateObject
    private var viewModel = HomeViewModel()
    
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    
                    // MARK: Background
                    
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(
                                Color(
                                    .backgroundbgDefault
                                )
                            )
                            .ignoresSafeArea(
                                edges: .top
                            )
                            .frame(
                                width: geometry.size.width,
                                height: 320
                            )
                        
                        Rectangle()
                            .fill(
                                Color(
                                    .backgroundbgCanvas
                                )
                            )
                    }
                    
                    
                    // MARK: Main Content
                    
                    VStack {
                        header
                        
                        titleSection
                        
                        messageInput
                        
                        fastSpeechSection
                    }
                    .padding(
                        .horizontal,
                        20
                    )
                    .frame(
                        width: geometry.size.width
                    )
                    
                    
                    // MARK: Expanded Input
                    
                    if viewModel.isTextFieldExpanded {
                        ExpandedTextInputOverlay(
                            text: $viewModel.inputText,
                            characterCount:
                                viewModel.characterCount,
                            onTextChanged: { text in
                                viewModel.updateText(
                                    text
                                )
                            },
                            onSpeak: {
                                presentIfPossible(
                                    orientation:
                                        orientationMask(
                                            for:
                                                motionManager.pose
                                        )
                                )
                            },
                            onClose: {
                                viewModel
                                    .isTextFieldExpanded = false
                            }
                        )
                    }
                }
            }
            .navigationDestination(
                isPresented:
                    $isFastSpeechListPresented
            ) {
                FastSpeechView()
            }
            .navigationDestination(
                isPresented:
                    $isSettingsPresented
            ) {
                SettingView()
                    .toolbar(
                        .hidden,
                        for: .navigationBar
                    )
            }
            .onAppear {
                motionManager.start()
                
                AppDelegate.lock(
                    to: .portrait
                )
                
                adjustSelectedCategoryIndex()
            }
            .onDisappear {
                motionManager.stop()
            }
            .onChange(
                of: categories.count
            ) { _, _ in
                adjustSelectedCategoryIndex()
            }
            .onChange(
                of: motionManager.pose
            ) { _, pose in
                guard pose.isLandscape else {
                    isPresentationPresented = false
                    return
                }
                
                presentIfPossible(
                    orientation:
                        orientationMask(
                            for: pose
                        )
                )
            }
            .onChange(
                of: isPresentationPresented
            ) { wasPresented, isPresented in
                guard
                    wasPresented,
                    !isPresented
                else {
                    return
                }
                
                saveToRecentAndReset()
            }
            .onChange(
                of: motionManager.latestShakeID
            ) { _, _ in
                guard !isGesturePresented else {
                    return
                }
                
                isGesturePresented = true
            }
            .fullScreenCover(
                isPresented:
                    $isPresentationPresented
            ) {
                PresentationView(
                    text: viewModel.inputText,
                    orientation:
                        presentationOrientation
                )
            }
            .navigationDestination(
                isPresented: $isGesturePresented
            ) {
                DragGestureView()
                    .toolbar(
                        .hidden,
                        for: .navigationBar
                    )
            }
        }
        .ignoresSafeArea(
            .keyboard
        )
    }
}

// MARK: - Header

private extension HomeView {
    
    var header: some View {
        HStack {
            Image("AppIconImage")
                .resizable()
                .scaledToFit()
                .frame(
                    width: 50,
                    height: 34
                )
            
            Spacer()
            
            BasicButton(
                systemImage: "gearshape.fill",
                shape: .circle,
                foregroundStyle: .white,
                font: .system(
                    size: 24
                )
            ) {
                isSettingsPresented = true
            }
        }
        .padding(.top, 10)
    }
}

// MARK: - Title Section

private extension HomeView {
    
    var titleSection: some View {
        HStack {
            Text("말하기를\n시작해 볼까요?")
                .typography(
                    .largeTitleBold
                )
                .foregroundColor(
                    .textwhite
                )
                .multilineTextAlignment(
                    .leading
                )
            
            Spacer()
            
            VStack(
                alignment: .trailing,
                spacing: 4
            ) {
                Image(
                    systemName:
                        "rectangle.portrait.rotate"
                )
                .font(
                    .system(
                        size: 28
                    )
                )
                .foregroundColor(
                    .iconinverse
                )
                
                Text("가로로 돌려\n표현하기")
                    .typography(
                        .bodyMedium
                    )
                    .multilineTextAlignment(
                        .trailing
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                    .foregroundColor(
                        .textwhite
                    )
            }
        }
    }
}

// MARK: - Message Input

private extension HomeView {
    
    var messageInput: some View {
        MessageInputView(
            text:
                $viewModel.inputText,
            isExpanded:
                $viewModel.isTextFieldExpanded,
            characterCount:
                viewModel.characterCount,
            onTextChanged: { text in
                viewModel.updateText(
                    text
                )
            },
            onSpeak: {
                presentIfPossible(
                    orientation:
                        orientationMask(
                            for:
                                motionManager.pose
                        )
                )
            }
        )
        .frame(
            width: 362,
            height: 204
        )
        .frame(
            maxWidth: .infinity
        )
        .padding(
            .bottom,
            16
        )
        .opacity(
            viewModel.isTextFieldExpanded
            ? 0
            : 1
        )
    }
}

// MARK: - Fast Speech Section

private extension HomeView {
    
    var fastSpeechSection: some View {
        FastSpeechSection(
            categories:
                categories,
            
            recentPhrases:
                recentPhrases,
            
            selectedCategoryIndex:
                $viewModel.selectedCategoryIndex,
            
            selectedPhraseID:
                viewModel.selectedPhraseID,
            
            previewText: { text in
                viewModel.previewText(
                    for: text
                )
            },
            
            onPhraseSelected: { phrase in
                viewModel.selectPhrase(
                    phrase
                )
            },
            
            onShowAllFastSpeech: {
                isFastSpeechListPresented = true
            }
        )
        .frame(maxWidth: .infinity)
        .padding(
            .bottom,
            20
        )
    }
}

// MARK: - Category Index

private extension HomeView {
    
    func adjustSelectedCategoryIndex() {
        
        let maximumIndex = categories.count
        
        guard maximumIndex > 0 else {
            viewModel.selectedCategoryIndex = 0
            return
        }
        
        guard
            viewModel.selectedCategoryIndex >= 0,
            viewModel.selectedCategoryIndex <= maximumIndex
        else {
            viewModel.selectedCategoryIndex = 1
            return
        }
    }
}

// MARK: - Presentation

private extension HomeView {
    
    func presentIfPossible(
        orientation:
        UIInterfaceOrientationMask
    ) {
        let trimmedText =
        viewModel.inputText
            .trimmingCharacters(
                in:
                        .whitespacesAndNewlines
            )
        
        guard !trimmedText.isEmpty else {
            return
        }
        
        viewModel.isTextFieldExpanded = false
        
        AppDelegate.orientationLock =
        orientation
        
        presentationOrientation =
        orientation
        
        isPresentationPresented = true
    }
}

// MARK: - Orientation

private extension HomeView {
    
    func orientationMask(
        for pose: MotionPose
    ) -> UIInterfaceOrientationMask {
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

// MARK: - 최근 문구 저장

private extension HomeView {
    
    func saveToRecentAndReset() {
        let text =
        viewModel.inputText
            .trimmingCharacters(
                in:
                        .whitespacesAndNewlines
            )
        
        guard !text.isEmpty else {
            return
        }
        
        let phrase = FastSpeechPhrase(
            text: text,
            sortOrder: 0,
            category: nil
        )
        
        modelContext.insert(
            phrase
        )
        
        do {
            try modelContext.save()
        } catch {
            print(
                "최근 문구 저장 실패: \(error)"
            )
        }
        
        viewModel.updateText("")
    }
}

// MARK: - Preview

#Preview("Home View - Mock Fast Speech") {
    HomeViewPreview()
        .modelContainer(
            for: [
                FastSpeechCategory.self,
                FastSpeechPhrase.self
            ],
            inMemory: true
        )
}

private struct HomeViewPreview: View {
    
    @Environment(
        \.modelContext
    )
    private var modelContext
    
    @State
    private var hasInsertedMockData = false
    
    var body: some View {
        HomeView()
            .task {
                guard !hasInsertedMockData else {
                    return
                }
                
                insertMockData()
                
                hasInsertedMockData = true
            }
    }
    
    private func insertMockData() {
        
        let category = FastSpeechCategory(
            name: "일상",
            sortOrder: 0
        )
        
        modelContext.insert(
            category
        )
        
        let phrases = [
            FastSpeechPhrase(
                text:
                    "잠시만 기다려 주세요.",
                sortOrder: 0,
                category: category
            ),
            
            FastSpeechPhrase(
                text:
                    "천천히 말씀해 주세요.",
                sortOrder: 1,
                category: category
            ),
            
            FastSpeechPhrase(
                text:
                    "제가 글로 적어서 보여드릴게요.",
                sortOrder: 2,
                category: category
            ),
            
            FastSpeechPhrase(
                text:
                    "지금 말씀을 이해하기 어려워요.",
                sortOrder: 3,
                category: category
            )
        ]
        
        for phrase in phrases {
            modelContext.insert(
                phrase
            )
        }
        
        do {
            try modelContext.save()
        } catch {
            print(
                "Mock data save failed: \(error)"
            )
        }
    }
}
