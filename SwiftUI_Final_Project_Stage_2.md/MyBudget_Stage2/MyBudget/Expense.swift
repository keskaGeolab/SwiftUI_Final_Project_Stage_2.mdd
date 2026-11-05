import Foundation

struct Expense: Identifiable {
    let id = UUID()
    let title: String
    let amount: Double
    let category: String
    let date: Date
}
