//
//  AuthenticationRootView.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 30/05/2025.
//
import SwiftUI

enum AuthenticationRoute: Route {
    case signIn
    case verifyEmail
}

struct AuthenticationRootView: View {
    @EnvironmentObject var appSwitch: AppSwitch
    
    var body: some View {
        VStack {
            Text("Authentication")
            
            Button("Continue as Guest") {
                appSwitch.switchTo(.mainTabs)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
