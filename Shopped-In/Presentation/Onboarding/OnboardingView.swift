
import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appSwitch: AppSwitch
    
    var body: some View {
        VStack {
            Text("onboarding")
            
            Button("Finish") {
                appSwitch.switchTo(.authentication)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    OnboardingView().environmentObject(AppSwitch())
}
