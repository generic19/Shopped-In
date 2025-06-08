//
//  ContentView.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 29/05/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appSwitch = AppSwitch()
    
    var body: some View {

        AppSwitchView()
            .environmentObject(appSwitch)

    }
}

#Preview {
    ContentView()
}
