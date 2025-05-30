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
    @State var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            SignUpView()
                .navigationDestination(for: AuthenticationRoute.self) { route in
                    switch route {
                        case .signIn: SignInView()
                        case .verifyEmail: VerifyEmailView()
                    }
                }
        }
    }
}

