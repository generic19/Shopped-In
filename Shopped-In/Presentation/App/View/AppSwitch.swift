//
//  Switch.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 30/05/2025.
//
import SwiftUI

enum SwitchRoute {
    case splash
    case onboarding
    case authentication
    case mainTabs
}

final class AppSwitch: ObservableObject {
    @Published var selectedRoute: SwitchRoute = .authentication
    
    func switchTo(_ route: SwitchRoute) {
        self.selectedRoute = route
    }
}
