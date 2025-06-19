//
//  ToastView.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 13/06/2025.
//

import SwiftUI

struct ToastView: View {
    let message: String
    let backgroundColor: Color

    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .padding()
                .background(backgroundColor.opacity(0.85))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.bottom, 40)
                .transition(.opacity)
                .frame(minWidth: 250)
        }
        .animation(.easeInOut, value: message)
    }
}
