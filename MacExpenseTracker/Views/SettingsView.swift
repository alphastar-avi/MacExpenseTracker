import SwiftUI
import SwiftData

struct SettingsView: View {
    var onBack: () -> Void
    var onSignOut: () -> Void
    
    @State private var viewModel = SettingsViewModel()
    @Environment(\.modelContext) private var modelContext
    
    @State private var isEditingName = false
    @State private var tempName = ""
    @State private var newCategory = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onBack) {
                Label("Back", systemImage: "arrow.left")
                    .padding(12)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            .padding(.top, 16)
            .padding(.horizontal, 16)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Security")
                            .font(.headline)
                        
                        Text("Secure your local vault with a passcode. If enabled, you must enter it when launching the app.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Toggle("Require Passcode", isOn: $viewModel.isPasscodeEnabled)
                            .onChange(of: viewModel.isPasscodeEnabled) { _, enabled in
                                if !enabled {
                                    viewModel.savePasscode()
                                }
                            }
                        
                        if viewModel.isPasscodeEnabled {
                            HStack {
                                SecureField("New Passcode", text: $viewModel.newPasscode)
                                    .textFieldStyle(.roundedBorder)
                                    .onSubmit { viewModel.savePasscode() }
                                
                                Button(action: { viewModel.savePasscode() }) {
                                    Text("Save")
                                }
                            }
                        }
                        
                        if !viewModel.passcodeMessage.isEmpty {
                            Text(viewModel.passcodeMessage)
                                .font(.caption)
                                .foregroundColor(viewModel.passcodeMessage.contains("disabled") ? .secondary : (viewModel.passcodeMessage.contains("empty") ? .red : .green))
                        }
                        
                        if viewModel.isPasscodeEnabled {
                            Divider()
                                .padding(.vertical, 8)
                            
                            Button(action: { viewModel.signOut() }) {
                                Text("Lock Vault")
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                            }
                            .buttonStyle(.plain)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary, lineWidth: 1))
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(NSColor.windowBackgroundColor))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Expense Categories")
                            .font(.headline)
                        
                        if viewModel.categories.isEmpty {
                            Text("No categories. Add one below.")
                                .foregroundStyle(.secondary)
                        } else {
                            if #available(macOS 13.0, *) {
                                FlowLayout(spacing: 8) {
                                    ForEach(viewModel.categories, id: \.self) { cat in
                                        HStack(spacing: 4) {
                                            Text(cat)
                                            Button(action: { viewModel.removeCategory(cat) }) {
                                                Image(systemName: "xmark")
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.secondary.opacity(0.1))
                                        .cornerRadius(16)
                                    }
                                }
                            }
                        }
                        
                        HStack {
                            TextField("New category", text: $newCategory)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit { addCategory() }
                            
                            Button(action: addCategory) {
                                Label("Add", systemImage: "plus")
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(NSColor.windowBackgroundColor))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Export Data")
                            .font(.headline)
                        
                        Text("Download all your transactions as a single CSV file.")
                            .foregroundStyle(.secondary)
                        
                        Button(action: { viewModel.exportAllTransactions() }) {
                            Label("Download All Transactions", systemImage: "arrow.down.circle")
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary, lineWidth: 1))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(NSColor.windowBackgroundColor))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                    
                }
                .padding(24)
                .frame(maxWidth: 600, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.underPageBackgroundColor))
        .onAppear {
            viewModel.modelContext = modelContext
            viewModel.onSignOut = onSignOut
            viewModel.loadData()
        }
    }
    
    private func addCategory() {
        if !newCategory.isEmpty {
            viewModel.addCategory(newCategory)
            newCategory = ""
        }
    }
}

@available(macOS 13.0, *)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var height: CGFloat = 0
        for row in rows {
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            height += rowHeight + spacing
        }
        return CGSize(width: proposal.width ?? 0, height: height - spacing)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for view in row {
                let size = view.sizeThatFits(.unspecified)
                view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }
    
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        var rows: [[LayoutSubview]] = [[]]
        var width: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if width + size.width > maxWidth && !rows[rows.count - 1].isEmpty {
                rows.append([view])
                width = size.width + spacing
            } else {
                rows[rows.count - 1].append(view)
                width += size.width + spacing
            }
        }
        return rows
    }
}
