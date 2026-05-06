import SwiftUI

struct SankeyNode: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    var rect: CGRect = .zero
    var color: Color
}

struct SankeyLink: Identifiable {
    let id = UUID()
    let sourceId: UUID
    let targetId: UUID
    let value: Double
    var startYOffset: CGFloat = 0
    var targetYOffset: CGFloat = 0
    var color: Color
}

struct SankeyChartView: View {
    var transactions: [Transaction]
    var isLoading: Bool
    
    let category10: [Color] = [
        Color(red: 31/255, green: 119/255, blue: 180/255),
        Color(red: 255/255, green: 127/255, blue: 14/255),
        Color(red: 44/255, green: 160/255, blue: 44/255),
        Color(red: 214/255, green: 39/255, blue: 40/255),
        Color(red: 148/255, green: 103/255, blue: 189/255),
        Color(red: 140/255, green: 86/255, blue: 75/255),
        Color(red: 227/255, green: 119/255, blue: 194/255),
        Color(red: 127/255, green: 127/255, blue: 127/255),
        Color(red: 188/255, green: 189/255, blue: 34/255),
        Color(red: 23/255, green: 190/255, blue: 207/255)
    ]
    
    var body: some View {
        Group {
            if isLoading {
                Text("Loading Activity...")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if transactions.isEmpty {
                Text("No data for the selected period.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                GeometryReader { geo in
                    drawSankey(in: geo.size)
                }
                .padding(20)
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func drawSankey(in size: CGSize) -> some View {
        let nodeWidth: CGFloat = 18
        let nodeSpacing: CGFloat = 24
        
        // Data processing
        var incomeMap: [String: Double] = [:]
        var expenseMap: [String: Double] = [:]
        
        for tx in transactions {
            if tx.type == "income" {
                let key = tx.title.isEmpty ? "Other Income" : tx.title
                incomeMap[key, default: 0] += tx.amount
            } else {
                let key = tx.category.isEmpty ? "Other Expense" : tx.category
                expenseMap[key, default: 0] += tx.amount
            }
        }
        
        let sortedIncomes = incomeMap.map { (label: $0.key, value: $0.value) }.sorted(by: { $0.value > $1.value })
        let sortedExpenses = expenseMap.map { (label: $0.key, value: $0.value) }.sorted(by: { $0.value > $1.value })
        
        let totalIncome = sortedIncomes.reduce(0) { $0 + $1.value }
        let totalExpense = sortedExpenses.reduce(0) { $0 + $1.value }
        let totalMax = max(totalIncome, totalExpense)
        let totalBudget = totalMax // Budget node height is totalMax
        
        guard totalMax > 0 else {
            return AnyView(Text("No valid data.").frame(maxWidth: .infinity, maxHeight: .infinity))
        }
        
        let maxNodesInCol = max(max(sortedIncomes.count, sortedExpenses.count), 1)
        let availableHeight = max(0, size.height - CGFloat(maxNodesInCol - 1) * nodeSpacing)
        let pixelsPerValue = availableHeight / totalMax
        
        var incomes: [SankeyNode] = []
        var expenses: [SankeyNode] = []
        var colorIdx = 0
        
        for inc in sortedIncomes {
            incomes.append(SankeyNode(label: inc.label, value: inc.value, color: category10[colorIdx % 10]))
            colorIdx += 1
        }
        var budgetNode = SankeyNode(label: "Budget", value: totalBudget, color: category10[colorIdx % 10])
        colorIdx += 1
        for exp in sortedExpenses {
            expenses.append(SankeyNode(label: exp.label, value: exp.value, color: category10[colorIdx % 10]))
            colorIdx += 1
        }
        
        let col0_x: CGFloat = 0
        let col1_x: CGFloat = (size.width - nodeWidth) / 2
        let col2_x: CGFloat = size.width - nodeWidth
        
        // Layout Incomes
        var currentY: CGFloat = (size.height - (CGFloat(incomes.count) * nodeSpacing + totalIncome * pixelsPerValue) + nodeSpacing) / 2
        for i in 0..<incomes.count {
            let h = incomes[i].value * pixelsPerValue
            incomes[i].rect = CGRect(x: col0_x, y: currentY, width: nodeWidth, height: h)
            currentY += h + nodeSpacing
        }
        
        // Layout Budget
        let budgetH = budgetNode.value * pixelsPerValue
        let budgetY = (size.height - budgetH) / 2
        budgetNode.rect = CGRect(x: col1_x, y: budgetY, width: nodeWidth, height: budgetH)
        
        // Layout Expenses
        currentY = (size.height - (CGFloat(expenses.count) * nodeSpacing + totalExpense * pixelsPerValue) + nodeSpacing) / 2
        for i in 0..<expenses.count {
            let h = expenses[i].value * pixelsPerValue
            expenses[i].rect = CGRect(x: col2_x, y: currentY, width: nodeWidth, height: h)
            currentY += h + nodeSpacing
        }
        
        // Links
        var links: [SankeyLink] = []
        var budgetIncomeOffset: CGFloat = 0
        var budgetExpenseOffset: CGFloat = 0
        
        for inc in incomes {
            links.append(SankeyLink(sourceId: inc.id, targetId: budgetNode.id, value: inc.value, startYOffset: 0, targetYOffset: budgetIncomeOffset, color: inc.color))
            budgetIncomeOffset += inc.value * pixelsPerValue
        }
        
        for exp in expenses {
            links.append(SankeyLink(sourceId: budgetNode.id, targetId: exp.id, value: exp.value, startYOffset: budgetExpenseOffset, targetYOffset: 0, color: exp.color))
            budgetExpenseOffset += exp.value * pixelsPerValue
        }
        
        return AnyView(
            Canvas { context, size in
                // Draw Links
                for link in links {
                    let sourceNode = incomes.first(where: { $0.id == link.sourceId }) ?? budgetNode
                    let targetNode = expenses.first(where: { $0.id == link.targetId }) ?? budgetNode
                    
                    let linkThickness = link.value * pixelsPerValue
                    guard linkThickness > 0.5 else { continue }
                    
                    let startX = sourceNode.rect.maxX
                    let startY = sourceNode.rect.minY + link.startYOffset + linkThickness / 2
                    
                    let endX = targetNode.rect.minX
                    let endY = targetNode.rect.minY + link.targetYOffset + linkThickness / 2
                    
                    var path = Path()
                    path.move(to: CGPoint(x: startX, y: startY))
                    let cp1 = CGPoint(x: (startX + endX) / 2, y: startY)
                    let cp2 = CGPoint(x: (startX + endX) / 2, y: endY)
                    path.addCurve(to: CGPoint(x: endX, y: endY), control1: cp1, control2: cp2)
                    
                    // Linear Gradient
                    let gradient = Gradient(colors: [link.color.opacity(0.3), targetNode.id == budgetNode.id ? budgetNode.color.opacity(0.3) : link.color.opacity(0.3)])
                    context.stroke(path, with: .linearGradient(gradient, startPoint: CGPoint(x: startX, y: 0), endPoint: CGPoint(x: endX, y: 0)), lineWidth: linkThickness)
                }
                
                // Draw Nodes
                let allNodes = incomes + [budgetNode] + expenses
                
                for node in allNodes {
                    guard node.rect.height > 0 else { continue }
                    let rectPath = Path(roundedRect: node.rect, cornerRadius: 2)
                    context.fill(rectPath, with: .color(node.color.opacity(0.8)))
                    
                    // Label
                    let text = Text(node.label).font(.caption).foregroundColor(.primary)
                    let resolvedText = context.resolve(text)
                    
                    if node.rect.minX == col0_x {
                        context.draw(resolvedText, at: CGPoint(x: node.rect.maxX + 16, y: node.rect.midY), anchor: .leading)
                    } else if node.rect.minX == col2_x {
                        context.draw(resolvedText, at: CGPoint(x: node.rect.minX - 16, y: node.rect.midY), anchor: .trailing)
                    } else {
                        context.draw(resolvedText, at: CGPoint(x: node.rect.midX, y: node.rect.minY - 16), anchor: .bottom)
                    }
                }
            }
        )
    }
}
