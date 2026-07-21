//
//  DragHeader.swift
//  Mogapa
//
//  Created by Sue on 7/21/26.
//

import SwiftUI

struct DragHeader: View {

    let onEditTap: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("드래그 제스처로\n빠른 말하기")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Text("드래그 후 손을 떼면 출력 후 자동 종료")
                    .font(.body)
                    .foregroundStyle(.white)
            }

            Spacer()

            BasicButton(
                title: "편집",
                foregroundStyle: .white
            ) {
                onEditTap()
            }
        }
    }
}

#Preview {
    DragHeader(onEditTap: {})
        .background(.black)
}
