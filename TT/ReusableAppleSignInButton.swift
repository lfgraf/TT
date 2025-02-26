import SwiftUI
import AuthenticationServices

struct ReusableAppleSignInButton: View {
    var onCompletion: (Result<ASAuthorization, Error>) -> Void
    var buttonStyle: SignInWithAppleButton.Style = .black
    var buttonType: SignInWithAppleButton.Label = .signIn
    
    var body: some View {
        SignInWithAppleButton(
            buttonType,
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            },
            onCompletion: onCompletion
        )
        .signInWithAppleButtonStyle(buttonStyle)
        .frame(height: 50)
    }
}