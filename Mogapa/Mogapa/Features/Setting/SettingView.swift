//
//  SettingView.swift
//  Mogapa
//
//  Created by 김지원 on 7/21/26.
//

import SwiftUI

struct SettingView: View {
    @AppStorage("settings.playbackSpeed") private var playbackSpeed = 50.0
    @AppStorage("settings.voicePitch") private var voicePitch = 50.0
    @AppStorage("settings.isBrightnessOn") private var isBrightnessOn = true
    @AppStorage("settings.manualBrightness") private var manualBrightness = 50.0
    @AppStorage("settings.isRotateOn") private var isRotateOn = true
    @Environment(\.dismiss) private var dismiss

    // 재설정 버튼 활성/비활성 판단 기준값
    private let defaultPlaybackSpeed = 50.0
    private let defaultVoicePitch = 50.0
    private let defaultIsBrightnessOn = true
    private let defaultManualBrightness = 50.0
    private let defaultIsRotateOn = true

    private var hasChanges: Bool {
        playbackSpeed != defaultPlaybackSpeed ||
        voicePitch != defaultVoicePitch ||
        isBrightnessOn != defaultIsBrightnessOn ||
        manualBrightness != defaultManualBrightness ||
        isRotateOn != defaultIsRotateOn
    }

    var body: some View {
        VStack(spacing: 0){
            // 앱 공용 헤더 컴포넌트 재사용
            MogapaNavigationHeader(
                title: "설정",
                rightTitle: "재설정",
                isRightDisabled: !hasChanges,
                rightForegroundStyle: Color.textsecondary.opacity(hasChanges ? 1 : 0.4),
                onLeftTap: {dismiss()},
                onRightTap: {
                    playbackSpeed = defaultPlaybackSpeed
                    voicePitch = defaultVoicePitch
                    isBrightnessOn = defaultIsBrightnessOn
                    manualBrightness = defaultManualBrightness
                    isRotateOn = defaultIsRotateOn
                },
                backgroundColor: Color("Backgroundbg-disabled")
            )
            
            // 재생 속도
            SettingSectionContainer(title: "재생 속도") {
                SliderRow(value: $playbackSpeed)
            }
            .padding(.top, 8)
            
            // 목소리 높낮이
            SettingSectionContainer(title: "목소리 높낮이") {
                SliderRow(
                    value: $voicePitch,
                    minimumIcon: "waveform.path.ecg",
                    maximumIcon: "waveform.path"
                )
            }
            .padding(.top, 20)
            
            // 프레젠테이션뷰 자동 밝기
            SettingSectionContainer(title: "프레젠테이션뷰 밝기 조절") {
                VStack(spacing: 0) {
                    ToggleRow(label: "자동 밝기", isOn: $isBrightnessOn)
                    
                    if !isBrightnessOn {
                        Divider()
                            .padding(.leading, 20)
                        
                        SliderRow(
                            value: $manualBrightness,
                            minimumIcon: "sun.min",
                            maximumIcon: "sun.max"
                        )
                    }
                }
            }
            .padding(.top, 20)
            
            // 프레젠테이션뷰 가로 전환
            SettingSectionContainer(title: "프레젠테이션뷰 가로 전환") {
                ToggleRow(label: "자동 전환", isOn: $isRotateOn)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .background(Color("Backgroundbg-disabled"))
        .environment(\.locale, Locale(identifier: "ko"))
    }
}

#Preview {
    SettingView()
}
