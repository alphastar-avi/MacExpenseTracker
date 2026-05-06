import SwiftUI

struct ExpenseFormView: View {
    @Binding var categories: [String]
    var onSubmit: (String, Double, String) -> Void
    
    @State private var selectedCategory: String = ""
    @State private var amountString: String = ""
    @State private var descriptionText: String = ""
    @State private var isSubmitting = false
    
    let customBlue = Color(red: 59/255, green: 118/255, blue: 175/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Expense")
                .font(.headline)
                .foregroundStyle(customBlue)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Category")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Picker("", selection: $selectedCategory) {
                        if selectedCategory == "" {
                            Text("Select Category").tag("")
                        }
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Amount")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("0.00", text: $amountString)
                        .textFieldStyle(.roundedBorder)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Description")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("Details...", text: $descriptionText)
                    .textFieldStyle(.roundedBorder)
            }
            
            Button(action: submit) {
                Text(isSubmitting ? "Adding..." : "Add Expense")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            .background(customBlue)
            .cornerRadius(6)
            .disabled(amountString.isEmpty || selectedCategory.isEmpty || isSubmitting)
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            if selectedCategory.isEmpty, let first = categories.first {
                selectedCategory = first
            }
        }
        .onChange(of: categories) { _, newCats in
            if !newCats.contains(selectedCategory), let first = newCats.first {
                selectedCategory = first
            }
        }
    }
    
    private func submit() {
        guard let amount = Double(amountString) else { return }
        isSubmitting = true
        onSubmit(selectedCategory, amount, descriptionText)
        amountString = ""
        descriptionText = ""
        if let first = categories.first {
            selectedCategory = first
        }
        isSubmitting = false
    }
}
