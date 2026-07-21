//
//  View.Extension.swift
//  Mogapa
//
//  Created by sun on 7/21/26.
//

import SwiftUI

extension View {
    /// 현재 화면에서 키보드를 내리기
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
