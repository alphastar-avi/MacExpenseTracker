import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var showSettings = false
    
    var body: some View {
        Group {
            if isLoggedIn {
                if showSettings {
                    SettingsView(onBack: {
                        showSettings = false
                    }, onSignOut: {
                        isLoggedIn = false
                        showSettings = false
                    })
                } else {
                    DashboardView(onLogout: {
                        KeychainService.shared.delete(key: "session_active")
                        isLoggedIn = false
                        checkSession()
                    }, onSettings: {
                        showSettings = true
                    })
                }
            } else {
                LoginView(onLoginSuccess: {
                    isLoggedIn = true
                })
            }
        }
        .onAppear {
            checkSession()
        }
    }
    
    private func checkSession() {
        if KeychainService.shared.loadString(key: "app_passcode_hash") == nil {
            isLoggedIn = true // No passcode enabled, bypass login
        } else {
            if KeychainService.shared.loadString(key: "session_active") == "true" {
                isLoggedIn = true
            } else {
                isLoggedIn = false
            }
        }
    }
}
