import Foundation
import SwiftData

@Observable
class AuthViewModel {
    var password = ""
    var errorMessage = ""
    var isLoading = false
    
    var onLoginSuccess: (() -> Void)?
    
    func submit() {
        errorMessage = ""
        
        if password.isEmpty {
            errorMessage = "Passcode is required."
            return
        }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isLoading = false
            
            if let storedHash = KeychainService.shared.loadString(key: "app_passcode_hash") {
                if self.password.sha256 == storedHash {
                    KeychainService.shared.saveString(key: "session_active", value: "true")
                    self.onLoginSuccess?()
                } else {
                    self.errorMessage = "Invalid passcode."
                }
            } else {
                // If there's no passcode, we shouldn't even be here, but just in case:
                self.onLoginSuccess?()
            }
        }
    }
}
