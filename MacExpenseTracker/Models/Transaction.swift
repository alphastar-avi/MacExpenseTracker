import Foundation
import SwiftData

@Model
final class Transaction {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var type: String // "income" or "expense"
    var amount: Double
    var category: String
    var transactionDescription: String // 'description' is a reserved word in NSObject, so using 'transactionDescription'
    var title: String
    var transactionDate: Date
    var createdAt: Date
    
    init(id: UUID = UUID(), userId: UUID, type: String, amount: Double, category: String, transactionDescription: String = "", title: String = "", transactionDate: Date, createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.type = type
        self.amount = amount
        self.category = category
        self.transactionDescription = transactionDescription
        self.title = title
        self.transactionDate = transactionDate
        self.createdAt = createdAt
    }
}
