import SwiftUI

struct IncomeFormView: View {
    var onSubmit: (String, Double) -> Void
    
    @State private var title: String = ""
    @State private var amountString: String = ""
    @State private var isSubmitting = false
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Source Title")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("e.g. Salary", text: $title)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Amount")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("0.00", text: $amountString)
                    .textFieldStyle(.roundedBorder)
            }
            
            Button(action: submit) {
                Text(isSubmitting ? "Adding..." : "Add Income")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(Color.green)
            .cornerRadius(6)
            .disabled(amountString.isEmpty || isSubmitting)
            .padding(.top, 4)
        }
        .padding()
    }
    
    private func submit() {
        guard let amount = Double(amountString) else { return }
        isSubmitting = true
        onSubmit(title, amount)
        title = ""
        amountString = ""
        isSubmitting = false
    }
}
