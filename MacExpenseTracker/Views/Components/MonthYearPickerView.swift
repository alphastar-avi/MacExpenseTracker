import SwiftUI

struct MonthYearPickerView: View {
    @Binding var selectedMonth: Int
    @Binding var selectedYear: Int
    var onIncomeSubmit: (String, Double) -> Void
    
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    let years = Array(2020...2056)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Select Period")
                    .font(.headline)
                Text("Choose a month and year, then add income.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Picker("Month", selection: $selectedMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text(months[month - 1]).tag(month)
                    }
                }
                .labelsHidden()
                
                Picker("Year", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .labelsHidden()
            }
            
            Divider()
            
            Text("Add Income Source")
                .font(.headline)
            
            IncomeFormView(onSubmit: onIncomeSubmit)
        }
        .padding()
        .frame(width: 320)
    }
}
