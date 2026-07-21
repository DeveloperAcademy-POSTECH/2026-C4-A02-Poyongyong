//
//  SettingView.swift
//  Mogapa
//
//  Created by 김지원 on 7/21/26.
//

import SwiftUI

struct SettingView: View {
    @State private var playbackSpeed = 50.0
    @State private var voicePitch = 50.0
    @State private var isBrightnessOn = true
    @State private var manualBrightness = 50.0
    @State private var isRotateOn = true
    
    var body: some View {
        VStack(spacing: 0){
            // 앱 공용 헤더 컴포넌트 재사용
            MogapaNavigationHeader(
                title: "설정",
                rightTitle: "재설정",
                onLeftTap: {},
                onRightTap: {},
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
