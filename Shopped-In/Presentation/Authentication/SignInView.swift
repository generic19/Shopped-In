import SwiftUI

struct SignInView: View {
    @EnvironmentObject var appSwitch: AppSwitch
    
    @FocusState private var focusedField: FocusedField?
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
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
                        .disabled(viewModel.isLoading)
                        .padding(.horizontal)
                        .padding(.top, 50)
                        
                        HStack {
                            Text("Don’t have an account?")
                            NavigationLink(destination: SignUpView(viewModel: viewModel)) {//viewmodel
                                Text("Sign Up")
                                    .foregroundColor(.blue)
                                    .underline()
                            }
                            .disabled(viewModel.isLoading)
                        }
                        .font(.system(size: 14))
                        .padding(.top, 8)
                        
                        Button(action: {
                            if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                                   viewModel.signInWithGoogle(presentingViewController: rootVC)
                               }
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
                        .disabled(viewModel.isLoading)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    .padding(.vertical)
                }
                
                if viewModel.isLoading {
                    ProgressView {
                        Text("Signing in...")
                    }
                    .padding(32)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .alert("Sign in Error", isPresented: $viewModel.shouldShowErrorAlert) {
                Button("Ok") { viewModel.errorMessage = nil }
            }
            message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
    }
}
