import Foundation
import SwiftData

@Observable
class DashboardViewModel {
    var selectedMonth: Int
    var selectedYear: Int
    
    var transactions: [Transaction] = []
    var isLoading = false
    
    var recentlyDeletedTransaction: Transaction? = nil
    
    var modelContext: ModelContext?
    
    init() {
        let currentDate = Date()
        let calendar = Calendar.current
        selectedMonth = calendar.component(.month, from: currentDate)
        selectedYear = calendar.component(.year, from: currentDate)
    }
    
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
    
    func fetchTransactions() {
        guard let context = modelContext, let userId = currentUserId else { return }
        
        isLoading = true
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        guard let startDate = calendar.date(from: components) else {
            isLoading = false
            return
        }
        
        guard let endDate = calendar.date(byAdding: .month, value: 1, to: startDate) else {
            isLoading = false
            return
        }
        
        let descriptor = FetchDescriptor<Transaction>()
        do {
            let all = try context.fetch(descriptor)
            self.transactions = all.filter { $0.userId == userId && $0.transactionDate >= startDate && $0.transactionDate < endDate }.sorted(by: { $0.createdAt > $1.createdAt })
            self.isLoading = false
        } catch {
            print("Failed to fetch transactions")
            self.isLoading = false
        }
    }
    
    func addIncome(title: String, amount: Double) {
        guard let context = modelContext, let userId = currentUserId else { return }
        let date = createTransactionDate()
        let tx = Transaction(userId: userId, type: "income", amount: amount, category: "Income", title: title.isEmpty ? "Other Income" : title, transactionDate: date)
        context.insert(tx)
        try? context.save()
        fetchTransactions()
        recentlyDeletedTransaction = nil
    }
    
    func addExpense(category: String, amount: Double, description: String) {
        guard let context = modelContext, let userId = currentUserId else { return }
        let date = createTransactionDate()
        let tx = Transaction(userId: userId, type: "expense", amount: amount, category: category, transactionDescription: description, transactionDate: date)
        context.insert(tx)
        try? context.save()
        fetchTransactions()
        recentlyDeletedTransaction = nil
    }
    
    func deleteTransaction(_ tx: Transaction) {
        guard let context = modelContext else { return }
        
        recentlyDeletedTransaction = Transaction(id: UUID(), userId: tx.userId, type: tx.type, amount: tx.amount, category: tx.category, transactionDescription: tx.transactionDescription, title: tx.title, transactionDate: tx.transactionDate, createdAt: tx.createdAt)
        
        context.delete(tx)
        try? context.save()
        fetchTransactions()
    }
    
    func undoDelete() {
        guard let context = modelContext, let tx = recentlyDeletedTransaction else { return }
        context.insert(tx)
        try? context.save()
        recentlyDeletedTransaction = nil
        fetchTransactions()
    }
    
    func exportCSV() {
        let filename = "transactions-\(selectedYear)-\(String(format: "%02d", selectedMonth)).csv"
        CSVExportService.shared.exportTransactions(transactions, suggestedFilename: filename)
    }
    
    private func createTransactionDate() -> Date {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 15
        components.hour = 12
        return Calendar.current.date(from: components) ?? Date()
    }
}
