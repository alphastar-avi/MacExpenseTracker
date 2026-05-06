import Foundation
import AppKit
import UniformTypeIdentifiers

class CSVExportService {
    static let shared = CSVExportService()
    
    func exportTransactions(_ transactions: [Transaction], suggestedFilename: String) {
        var csvString = "Date,Type,Title,Category,Amount,Description\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for tx in transactions {
            let date = dateFormatter.string(from: tx.transactionDate)
            let type = tx.type
            let title = tx.title.replacingOccurrences(of: "\"", with: "\"\"")
            let category = tx.category.replacingOccurrences(of: "\"", with: "\"\"")
            let amount = String(format: "%.2f", tx.amount)
            let description = tx.transactionDescription.replacingOccurrences(of: "\"", with: "\"\"")
            
            let row = "\(date),\(type),\"\(title)\",\"\(category)\",\(amount),\"\(description)\"\n"
            csvString.append(row)
        }
        
        DispatchQueue.main.async {
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [.commaSeparatedText]
            savePanel.nameFieldStringValue = suggestedFilename
            savePanel.canCreateDirectories = true
            
            savePanel.begin { response in
                if response == .OK, let url = savePanel.url {
                    do {
                        try csvString.write(to: url, atomically: true, encoding: .utf8)
                    } catch {
                        print("Error saving CSV: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
