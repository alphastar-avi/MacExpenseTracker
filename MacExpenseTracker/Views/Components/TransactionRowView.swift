import SwiftUI

struct TransactionRowView: View {
    var transaction: Transaction
    var onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.type == "income" ? transaction.title : transaction.category)
                    .font(.headline)
                    .foregroundStyle(transaction.type == "income" ? Color.green : Color.primary)
                
                if !transaction.transactionDescription.isEmpty {
                    Text(transaction.transactionDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Text(transaction.transactionDate.shortDateString)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text((transaction.type == "income" ? "+₹" : "-₹") + transaction.amount.currencyString)
                    .font(.headline)
                    .foregroundStyle(transaction.type == "income" ? Color.green : Color.red)
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}
