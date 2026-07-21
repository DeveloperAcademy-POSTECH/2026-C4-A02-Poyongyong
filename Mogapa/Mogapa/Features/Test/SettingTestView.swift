//
//  SettingTestView.swift
//  Mogapa
//
//  Created by Minjae Son on 7/21/26.
//

import SwiftUI

struct SettingsTestView: View {
    
    var body: some View {
        
        NavigationStack {
            
            VStack(
                spacing: 20
            ) {
                Text("설정")
                    .typography(.largeTitleBold)
                Text("Settings Test View")
                    .typography(.bodyMedium)
                    .foregroundStyle(.textmuted)
            }
            .frame(
                maxWidth:.infinity,
                maxHeight:.infinity
            )
            .navigationTitle("설정")
        }
    }
}

#Preview {
    SettingsTestView()
}
