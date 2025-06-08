import SwiftUI

struct SignInView: View {
    @FocusState private var focusedField: FocusedField?
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Welcome Back!")
                        .font(.system(size: 35, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)

                    Text("Please sign in to continue")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 30)

                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                        TextField("Email", text: $viewModel.email)
                            .focused($focusedField, equals: .email)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .keyboardType(.emailAddress)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(focusedField == .email ? Color.black : Color.white, lineWidth: 2))
                    .padding(.horizontal)

                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                        SecureField("Password", text: $viewModel.password)
                            .focused($focusedField, equals: .password)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(focusedField == .password ? Color.black : Color.white, lineWidth: 2))
                    .padding(.horizontal)

                    Button(action: {
                        viewModel.signIn()
                    }) {
                        Text("Sign In")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 50)

                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }

                    HStack {
                        Text("Don’t have an account?")
                        NavigationLink(destination: SignUpView(viewModel: viewModel)) {//viewmodel
                            Text("Sign Up")
                                .foregroundColor(.blue)
                                .underline()
                        }
                    }
                    .font(.system(size: 14))
                    .padding(.top, 8)

                    Button(action: {
                        // TODO: Google Sign-In
                    }) {
                        HStack {
                            Image("googleIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                            Text("Continue with Google")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.3)))
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.vertical)
            }
        }
    }
}
#Preview {
    let authRepository = AuthRepositoryImpl()
    let signInUseCase = SignInUseCase(authRepository: authRepository)
    let signUpUseCase = SignUpUseCase(authRepository: authRepository)
    let authViewModel = AuthViewModel(signUpUseCase: signUpUseCase, signInUseCase: signInUseCase)

    return SignInView(viewModel: authViewModel)
}
