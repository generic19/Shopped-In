

//  Welcome Screen.swift
//  Shopped-In
//
//  Created by Ayatullah Salah on 31/05/2025.
//


import Combine
import SwiftUI

struct AuthenticationWelcomeScreen: View {
    @StateObject var viewModel: AuthViewModel = DIContainer.shared.resolve()
    @EnvironmentObject var appSwitch: AppSwitch

    var body: some View {
        NavigationStack {
            ZStack {
                Image("fashion")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    Text("ShoppedIn")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 8)

                    Text("Explore the world of fashion")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Spacer()

                    VStack(spacing: 20) {
                        HStack(spacing: 20) {
                            NavigationLink(destination: SignInView(viewModel: viewModel)) {
                                Text("Login")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(width: 150, height: 50)
                                    .background(Color.white)
                                    .cornerRadius(10)
                            }

                            NavigationLink(destination: SignUpView(viewModel: viewModel)) {
                                Text("Signup")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 150, height: 50)
                                    .background(Color.black)
                                    .cornerRadius(10)
                            }
                        }

                        Text("Continue as Guest")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.white)
                            .underline()
                            .onTapGesture {
                                appSwitch.switchTo(.mainTabs)
                            }
                            .padding(.top, 10)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                }
            }
        }
        .onChange(of: viewModel.isAuthenticated) { _, newValue in
            if newValue {
                appSwitch.switchTo(.mainTabs)
            }
        }
    }
}

#Preview {
    AuthenticationWelcomeScreen()
}


