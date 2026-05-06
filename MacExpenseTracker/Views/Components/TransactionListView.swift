import SwiftUI

struct TransactionListView: View {
    var transactions: [Transaction]
    var recentlyDeleted: Transaction?
    var onUndo: () -> Void
    var onDelete: (Transaction) -> Void
    var onExport: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Transactions")
                    .font(.headline)
                Spacer()
                if !transactions.isEmpty {
                    Button(action: onExport) {
                        Label("Download CSV", systemImage: "arrow.down.circle")
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            ScrollView {
                VStack(spacing: 12) {
                    if let deleted = recentlyDeleted {
                        HStack {
                            Image(systemName: "arrow.uturn.backward")
                            Text("Undo delete: \(deleted.type == "income" ? deleted.title : deleted.category) — ₹\(deleted.amount.currencyString)")
                            Spacer()
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                                .foregroundColor(.secondary)
                        )
                        .onTapGesture {
                            onUndo()
                        }
                    }
                    
                    if transactions.isEmpty && recentlyDeleted == nil {
                        Text("No transactions found for this month.")
                            .foregroundStyle(.secondary)
                            .padding(.top, 40)
                    } else {
                        ForEach(transactions) { tx in
                            TransactionRowView(transaction: tx) {
                                onDelete(tx)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}
