//
//  ContentView.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 29/05/2025.
//

import SwiftUI
import SwiftData

enum AppRoute: Route {
    case onboarding
    case authentication
}

struct ContentView: View {
    @StateObject private var router = Router()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            SplashView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                        case .onboarding:
                            OnboardingView()
                            
                        case .authentication:
                            AuthenticationRootView()
                    }
                }
        }
        .environmentObject(router)
    }
}

#Preview {
    ContentView()
}
