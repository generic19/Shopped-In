//
//  AppSwitchView.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 30/05/2025.
//
import SwiftUI

enum AppRoute: Route {
    case splash
    case onboarding
    case authentication
    case mainTabs
}

struct AppSwitchView: View {
    @EnvironmentObject private var appSwitch: AppSwitch
    
    var body: some View {
        switch appSwitch.selectedRoute {
            case .splash: SplashView().environmentObject(appSwitch)
            case .onboarding: OnboardingView().environmentObject(appSwitch)
            case .authentication: AuthenticationWelcomeScreen().environmentObject(appSwitch)
            case .mainTabs: MainTabsView().environmentObject(appSwitch)
        }
    }
}
