

//  Welcome Screen.swift
//  Shopped-In
//
//  Created by Ayatullah Salah on 31/05/2025.
//

import SwiftUI
import Combine

struct AuthenticationWelcomeScreen: View {
    @StateObject var viewModel: AuthViewModel = {
        let tokenRepository: TokenRepo = StubTokenRepo()
        let apiService: APIService = APIService.shared
        let apiSource: APIAuthRemoteDataSource = APIAuthRemoteDataSourceImpl(service: apiService)
        let firebaseSource: FireBaseAuthRemoteDataSource = FireBaseAuthRemoteDataSourceImpl()
        let googleSource: GoogleAuthRemoteDataSource = GoogleAuthRemoteDataSourceImpl()  

        let authRepository = AuthRepositoryImpl(
            tokenRepository: tokenRepository,
            apiSource: apiSource,
            firebaseSource: firebaseSource,
            googleSource: googleSource
        )

        let signUpUseCase = SignUpUseCase(authRepository: authRepository)
        let signInUseCase = SignInUseCase(authRepository: authRepository)
        let getCurrentUserUseCase = GetCurrentUserUseCase(authRepository: authRepository)
        let signOutUseCase = SignOutUseCase(authRepository: authRepository)
        let signInWithGoogleUseCase = SignInWithGoogleUseCase(authRepository: authRepository) // ✅ هنا الإضافة

        return AuthViewModel(
            signUpUseCase: signUpUseCase,
            signInUseCase: signInUseCase,
            getCurrentUserUseCase: getCurrentUserUseCase,
            signOutUseCase: signOutUseCase,
            signInwithGoogleUseCase: signInWithGoogleUseCase
        )
    }()
    
    @EnvironmentObject var appSwitch: AppSwitch
    
    var body: some View {
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
        .onChange(of: viewModel.isAuthenticated) { oldValue, newValue in
            if newValue {
                appSwitch.switchTo(.mainTabs)
            }
        }
    }
}

#Preview {
    AuthenticationWelcomeScreen()
}
