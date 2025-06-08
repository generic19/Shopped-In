
import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        Text("sign up")
        Button("Sign in") {
            router.navigate(to: AuthenticationRoute.signIn)
        }
    }
}
