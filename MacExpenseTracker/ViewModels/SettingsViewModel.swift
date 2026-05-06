import Foundation
import SwiftData

@Observable
class SettingsViewModel {
    var categories: [String] = []
    
    var isPasscodeEnabled: Bool = false
    var newPasscode: String = ""
    var passcodeMessage: String = ""
    
    var modelContext: ModelContext?
    var onSignOut: (() -> Void)?
    
    var currentUserId: UUID? {
        guard let context = modelContext else { return nil }
        let fetchDescriptor = FetchDescriptor<User>()
        if let user = try? context.fetch(fetchDescriptor).first {
            return user.id
        } else {
            let newUser = User(name: "Local", email: "local@local", passwordHash: "")
            context.insert(newUser)
            try? context.save()
            return newUser.id
        }
    }
    
    private var categoriesKey: String {
        return "categories_\(currentUserId?.uuidString ?? "unknown")"
    }
    
    func loadData() {
        guard let _ = modelContext, let _ = currentUserId else { return }
        
        if let saved = UserDefaults.standard.stringArray(forKey: categoriesKey) {
            self.categories = saved
        } else {
            self.categories = ["Food", "Snacks", "Travel", "Others", "Gifts", "Health"]
            saveCategories()
        }
        
        if KeychainService.shared.loadString(key: "app_passcode_hash") != nil {
            isPasscodeEnabled = true
        } else {
            isPasscodeEnabled = false
        }
    }
    
    func savePasscode() {
        if isPasscodeEnabled {
            if !newPasscode.isEmpty {
                KeychainService.shared.saveString(key: "app_passcode_hash", value: newPasscode.sha256)
                passcodeMessage = "Passcode saved!"
                newPasscode = ""
            } else {
                passcodeMessage = "Passcode cannot be empty."
            }
        } else {
            KeychainService.shared.delete(key: "app_passcode_hash")
            KeychainService.shared.delete(key: "session_active")
            passcodeMessage = "Passcode disabled."
            newPasscode = ""
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.passcodeMessage = ""
        }
    }
    
    func addCategory(_ newCategory: String) {
        let trimmed = newCategory.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        if !categories.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            categories.append(trimmed)
            saveCategories()
        }
    }
    
    func removeCategory(_ category: String) {
        categories.removeAll { $0 == category }
        saveCategories()
    }
    
    private func saveCategories() {
        UserDefaults.standard.set(categories, forKey: categoriesKey)
    }
    
    func exportAllTransactions() {
        guard let context = modelContext, let userId = currentUserId else { return }
        let descriptor = FetchDescriptor<Transaction>()
        if let all = try? context.fetch(descriptor) {
            let userTxs = all.filter { $0.userId == userId }.sorted(by: { $0.transactionDate > $1.transactionDate })
            CSVExportService.shared.exportTransactions(userTxs, suggestedFilename: "all-transactions.csv")
        }
    }
    
    func signOut() {
        KeychainService.shared.delete(key: "session_user_id")
        onSignOut?()
    }
}
