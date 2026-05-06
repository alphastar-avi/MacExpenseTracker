import SwiftUI
import SwiftData

struct LoginView: View {
    @State private var viewModel = AuthViewModel()
    var onLoginSuccess: () -> Void
    
    var body: some View {
        VStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Unlock Vault")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Enter your passcode to unlock.")
                        .foregroundStyle(.secondary)
                }
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Passcode")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        SecureField("••••••••", text: $viewModel.password)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit {
                                viewModel.submit()
                            }
                    }
                }
                
                Button(action: {
                    viewModel.submit()
                }) {
                    Text(viewModel.isLoading ? "Unlocking..." : "Unlock")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .background(Color.accentColor)
                .cornerRadius(8)
                .disabled(viewModel.isLoading)
            }
            .padding(32)
            .frame(width: 400)
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.underPageBackgroundColor))
        .onAppear {
            viewModel.onLoginSuccess = onLoginSuccess
        }
    }
}
