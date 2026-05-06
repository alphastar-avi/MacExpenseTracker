import SwiftUI
import SwiftData

struct DashboardView: View {
    var onLogout: () -> Void
    var onSettings: () -> Void
    
    @State private var viewModel = DashboardViewModel()
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingDatePicker = false
    @State private var categories: [String] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("CashFlow")
                    .font(.system(size: 24, weight: .bold))
                
                Spacer()
                
                let monthName = DateFormatter().monthSymbols[viewModel.selectedMonth - 1]
                Button(action: { showingDatePicker.toggle() }) {
                    Label("\(monthName) \(viewModel.selectedYear)", systemImage: "calendar")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(6)
                .popover(isPresented: $showingDatePicker) {
                    MonthYearPickerView(selectedMonth: $viewModel.selectedMonth, selectedYear: $viewModel.selectedYear) { title, amount in
                        viewModel.addIncome(title: title, amount: amount)
                        showingDatePicker = false
                    }
                }
                .onChange(of: viewModel.selectedMonth) { _, _ in viewModel.fetchTransactions() }
                .onChange(of: viewModel.selectedYear) { _, _ in viewModel.fetchTransactions() }
                
                Divider()
                    .frame(height: 24)
                    .padding(.horizontal, 8)
                
                Button(action: onSettings) {
                    Image(systemName: "gearshape")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                
                Button(action: onLogout) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .padding(.leading, 8)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Main Content
            GeometryReader { geo in
                if geo.size.width > 900 {
                    // Two column layout
                    HStack(alignment: .top, spacing: 24) {
                        VStack(spacing: 24) {
                            SankeyChartView(transactions: viewModel.transactions, isLoading: viewModel.isLoading)
                                .frame(height: 350)
                            
                            ExpenseFormView(categories: $categories) { category, amount, description in
                                viewModel.addExpense(category: category, amount: amount, description: description)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        TransactionListView(transactions: viewModel.transactions, recentlyDeleted: viewModel.recentlyDeletedTransaction, onUndo: {
                            viewModel.undoDelete()
                        }, onDelete: { tx in
                            viewModel.deleteTransaction(tx)
                        }, onExport: {
                            viewModel.exportCSV()
                        })
                        .frame(width: 350)
                    }
                    .padding(24)
                } else {
                    // Vertical layout
                    ScrollView {
                        VStack(spacing: 24) {
                            SankeyChartView(transactions: viewModel.transactions, isLoading: viewModel.isLoading)
                                .frame(height: 350)
                            
                            ExpenseFormView(categories: $categories) { category, amount, description in
                                viewModel.addExpense(category: category, amount: amount, description: description)
                            }
                            
                            TransactionListView(transactions: viewModel.transactions, recentlyDeleted: viewModel.recentlyDeletedTransaction, onUndo: {
                                viewModel.undoDelete()
                            }, onDelete: { tx in
                                viewModel.deleteTransaction(tx)
                            }, onExport: {
                                viewModel.exportCSV()
                            })
                            .frame(height: 500)
                        }
                        .padding(24)
                    }
                }
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .background(Color(NSColor.underPageBackgroundColor))
        .onAppear {
            viewModel.modelContext = modelContext
            viewModel.fetchTransactions()
            loadCategories()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { _ in
            loadCategories()
        }
    }
    
    private func loadCategories() {
        let key = "categories_\(viewModel.currentUserId?.uuidString ?? "unknown")"
        if let saved = UserDefaults.standard.stringArray(forKey: key) {
            categories = saved
        } else {
            categories = ["Food", "Snacks", "Travel", "Others", "Gifts", "Health"]
            UserDefaults.standard.set(categories, forKey: key)
        }
    }
}
