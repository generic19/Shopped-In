//
//  Welcome Screen.swift
//  Shopped-In
//
//  Created by Ayatullah Salah on 31/05/2025.
//


import SwiftUI


struct WelcomeScreen: View {
    var body: some View {
        let authRepository = AuthRepositoryImpl()
        let signUpUseCase = SignUpUseCase(authRepository: authRepository)
        let signInUseCase = SignInUseCase(authRepository: authRepository)
        let viewModel = AuthViewModel(signUpUseCase: signUpUseCase, signInUseCase: signInUseCase)
        
        return NavigationStack {
            ZStack {
                Image("fashion")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    Text("ShppedIn")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 8)
                    
                    Text("explore the world of fashion")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
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
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}


#Preview {
    WelcomeScreen()
}
