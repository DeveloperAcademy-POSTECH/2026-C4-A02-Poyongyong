//
//  SliderRow.swift
//  Mogapa
//
//  Created by 김지원 on 7/21/26.
//

import SwiftUI

struct SliderRow: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let minimumIcon: String
    let maximumIcon: String
    
    init(
        value: Binding<Double>,
        range: ClosedRange<Double> = 0...100,
        minimumIcon: String = "tortoise.fill",
        maximumIcon: String = "hare.fill"
    ) {
        self._value = value
        self.range = range
        self.minimumIcon = minimumIcon
        self.maximumIcon = maximumIcon
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: minimumIcon)
                .foregroundStyle(Color("Iconmuted"))
            
            Slider(value: $value, in: range)
                .tint(.blue)
            
            Image(systemName: maximumIcon)
                .foregroundStyle(Color("Iconmuted"))
        }
        .padding(.horizontal, 24)
        .frame(height: 52)
    }
}

#Preview {
    SliderRow(value: .constant(30))
        .padding()
        .background(Color("Backgroundbg-disabled"))
}
