//
//  SpeechManager.swift
//  Mogapa
//
//  Created by sun on 7/21/26.
//

import AVFAudio
import Foundation
import Observation

@MainActor
@Observable
final class SpeechManager: NSObject {

    enum PlaybackState {
        case stopped
        case speaking
        case paused
    }

    private let synthesizer = AVSpeechSynthesizer()

    // 원본 전체 텍스트
    private(set) var activeText: String?

    // 현재 읽고 있는 범위
    // 원본 전체 텍스트 기준 UTF-16 NSRange
    private(set) var highlightedRange: NSRange?

    // 현재 읽고 있는 단어 시작 위치
    // 원본 전체 텍스트 기준 UTF-16 위치
    private(set) var spokenLength: Int = 0

    private(set) var playbackState: PlaybackState = .stopped

    // 잘라서 재생한 문자열이 원본에서 시작하는 위치
    private var playbackStartOffset: Int = 0

    // 현재 실제로 재생 중인 utterance
    @ObservationIgnored
    private var activeUtterance: AVSpeechUtterance?

    override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
    }

    // MARK: - 오디오 세션 설정

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: []
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("오디오 세션 설정 실패: \(error)")
        }
    }

    // MARK: - 처음부터 재생

    func play(_ text: String) {
        play(text, fromUTF16Offset: 0)
    }

    // MARK: - 특정 위치부터 재생

    func play(
        _ text: String,
        fromUTF16Offset offset: Int
    ) {
        let nsText = text as NSString

        guard nsText.length > 0 else {
            return
        }

        let safeOffset = min(
            max(offset, 0),
            nsText.length - 1
        )

        // 이전 발화 delegate 이벤트가
        // 새로운 발화 상태를 건드리지 않도록 먼저 해제
        activeUtterance = nil

        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let remainingText = nsText.substring(from: safeOffset)

        let utterance = AVSpeechUtterance(string: remainingText)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        activeText = text
        playbackStartOffset = safeOffset
        spokenLength = safeOffset
        highlightedRange = nil
        playbackState = .speaking
        activeUtterance = utterance

        synthesizer.speak(utterance)
    }

    // MARK: - 재생 / 일시정지 토글

    func toggle(_ text: String) {
        guard activeText == text else {
            play(text)
            return
        }

        switch playbackState {
        case .speaking:
            pause()

        case .paused:
            resume()

        case .stopped:
            play(text)
        }
    }

    // MARK: - 일시정지

    func pause() {
        guard synthesizer.isSpeaking else {
            return
        }

        if synthesizer.pauseSpeaking(at: .word) {
            playbackState = .paused
        }
    }

    // MARK: - 이어서 재생

    func resume() {
        guard synthesizer.isPaused else {
            return
        }

        if synthesizer.continueSpeaking() {
            playbackState = .speaking
        }
    }

    // MARK: - 정지

    func stop() {
        activeUtterance = nil

        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }

        clearState()
    }

    // MARK: - 상태 초기화

    private func clearState() {
        activeText = nil
        highlightedRange = nil
        spokenLength = 0
        playbackStartOffset = 0
        playbackState = .stopped
        activeUtterance = nil
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension SpeechManager: AVSpeechSynthesizerDelegate {

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        willSpeakRangeOfSpeechString characterRange: NSRange,
        utterance: AVSpeechUtterance
    ) {
        Task { @MainActor [weak self] in
            guard let self,
                  self.activeUtterance === utterance else {
                return
            }

            // characterRange는 잘린 문자열 기준이므로
            // 원본 전체 텍스트 기준 위치로 변환
            let originalRange = NSRange(
                location: self.playbackStartOffset
                    + characterRange.location,
                length: characterRange.length
            )

            self.spokenLength = originalRange.location
            self.highlightedRange = originalRange
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didStart utterance: AVSpeechUtterance
    ) {
        Task { @MainActor [weak self] in
            guard let self,
                  self.activeUtterance === utterance else {
                return
            }

            self.playbackState = .speaking
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didPause utterance: AVSpeechUtterance
    ) {
        Task { @MainActor [weak self] in
            guard let self,
                  self.activeUtterance === utterance else {
                return
            }

            self.playbackState = .paused
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didContinue utterance: AVSpeechUtterance
    ) {
        Task { @MainActor [weak self] in
            guard let self,
                  self.activeUtterance === utterance else {
                return
            }

            self.playbackState = .speaking
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        Task { @MainActor [weak self] in
            guard let self,
                  self.activeUtterance === utterance else {
                return
            }

            if let activeText = self.activeText {
                self.spokenLength = (activeText as NSString).length
            }

            self.highlightedRange = nil
            self.playbackState = .stopped
            self.activeUtterance = nil
            self.playbackStartOffset = 0
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        Task { @MainActor [weak self] in
            guard let self,
                  self.activeUtterance === utterance else {
                return
            }

            self.clearState()
        }
    }
}
