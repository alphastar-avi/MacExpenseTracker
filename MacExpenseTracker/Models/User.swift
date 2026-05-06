import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var name: String
    @Attribute(.unique) var email: String
    var passwordHash: String
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String, email: String, passwordHash: String, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.createdAt = createdAt
    }
}
