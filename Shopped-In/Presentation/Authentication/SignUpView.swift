import SwiftUI

enum FocusedField {
    case firstName, lastName, email, password, phone
}

struct Validator {
    static func validateEmail(_ email: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
}

struct SignUpView: View {
    @EnvironmentObject var appSwitch: AppSwitch
    
    @FocusState private var focusedField: FocusedField?
    @State private var isValidEmail: Bool = true
    
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Sign up here")
                        .font(.system(size: 35, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Welcome back you've been missed!")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.black)
                    
                    Group {
                        customTextField(icon: "person", placeholder: "First Name", text: $viewModel.firstName, field: .firstName)
                        customTextField(icon: "person", placeholder: "Last Name", text: $viewModel.lastName, field: .lastName)
                        customTextField(icon: "envelope", placeholder: "Email", text: $viewModel.email, field: .email)
                            .keyboardType(.emailAddress)
                            .onChange(of: viewModel.email) { newValue in
                                isValidEmail = Validator.validateEmail(newValue)
                            }
                        secureField(icon: "lock", placeholder: "Password", text: $viewModel.password, field: .password)
                        customTextField(icon: "phone", placeholder: "Phone", text: $viewModel.phone, field: .phone)
                            .keyboardType(.phonePad)
                    }
                    
                    Button(action: {
                        viewModel.signUp()
                    }) {
                        Text("Sign Up")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    .disabled(viewModel.isLoading)
                    
                    HStack {
                        Text("Already have an account?")
                        NavigationLink(destination: SignInView(viewModel: viewModel)) {
                            Text("Sign In")
                                .foregroundColor(.blue)
                                .underline()
                        }
                    }
                    .font(.system(size: 14))
                    .padding(.top, 8)
                    
                    Button(action: {
                        // Google sign-in logic here
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
                    Text("Signing up...")
                }
                .padding(32)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .alert("Sign up Error", isPresented: $viewModel.shouldShowErrorAlert) {
            Button("Ok") { viewModel.errorMessage = nil }
        }
        message: {
            Text( viewModel.errorMessage ?? "An error occurred")
        }
    }
    
    private func customTextField(icon: String, placeholder: String, text: Binding<String>, field: FocusedField) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            TextField(placeholder, text: text)
                .focused($focusedField, equals: field)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(focusedField == field ? Color.black : Color.white, lineWidth: 2))
        .padding(.horizontal)
    }
    
    private func secureField(icon: String, placeholder: String, text: Binding<String>, field: FocusedField) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            SecureField(placeholder, text: text)
                .focused($focusedField, equals: field)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(focusedField == field ? Color.black : Color.white, lineWidth: 2))
        .padding(.horizontal)
    }
}
