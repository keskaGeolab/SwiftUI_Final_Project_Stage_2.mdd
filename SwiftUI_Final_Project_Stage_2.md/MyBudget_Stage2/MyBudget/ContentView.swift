import SwiftUI

struct ContentView: View {
    @State private var expenses: [Expense] = [
        Expense(title: "სადილი", amount: 25, category: "საკვები", date: Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 3)) ?? .now),
        Expense(title: "ავტობუსი", amount: 2, category: "ტრანსპორტი", date: Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 2)) ?? .now),
        Expense(title: "კინო", amount: 30, category: "გართობა", date: Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 1)) ?? .now)
    ]

    @State private var showingAddExpense = false

    private var totalAmount: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ამ თვის ხარჯი")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.85))
                        Text(String(format: "%.2f ₾", totalAmount))
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(22)
                    .background(LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("ხარჯები")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            Button {
                                showingAddExpense = true
                            } label: {
                                Label("დამატება", systemImage: "plus")
                                    .fontWeight(.semibold)
                            }
                        }

                        if expenses.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "tray")
                                    .font(.system(size: 36))
                                    .foregroundStyle(.secondary)
                                Text("ხარჯები ჯერ არ არის დამატებული")
                                    .font(.headline)
                                Text("დამატებული ხარჯები აქ გამოჩნდება.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 36)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            VStack(spacing: 0) {
                                ForEach(expenses) { expense in
                                    ExpenseRow(expense: expense)
                                    if expense.id != expenses.last?.id {
                                        Divider().padding(.leading, 16)
                                    }
                                }
                            }
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("ჩემი ბიუჯეტი")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView { newExpense in
                    expenses.insert(newExpense, at: 0)
                }
            }
        }
    }
}

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (Expense) -> Void

    @State private var title = ""
    @State private var amountText = ""
    @State private var category = "საკვები"
    @State private var date = Date()
    @State private var errorMessage = ""

    private let categories = ["საკვები", "ტრანსპორტი", "გართობა", "სხვა"]

    var body: some View {
        NavigationStack {
            Form {
                Section("ხარჯის ინფორმაცია") {
                    TextField("მაგ. სადილი", text: $title)
                    HStack {
                        TextField("0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                        Text("₾").foregroundStyle(.secondary)
                    }
                    Picker("კატეგორია", selection: $category) {
                        ForEach(categories, id: \.self) { item in
                            Text(item).tag(item)
                        }
                    }
                    DatePicker("თარიღი", selection: $date, displayedComponents: .date)
                }

                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage).foregroundStyle(.red)
                    }
                }

                Section {
                    Button("შენახვა", action: saveExpense)
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                }
            }
            .navigationTitle("ახალი ხარჯი")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("გაუქმება") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveExpense() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanAmount = amountText.replacingOccurrences(of: ",", with: ".")
        guard !cleanTitle.isEmpty else {
            errorMessage = "გთხოვთ, შეიყვანოთ ხარჯის დასახელება."
            return
        }
        guard let amount = Double(cleanAmount), amount > 0 else {
            errorMessage = "გთხოვთ, შეიყვანოთ ნულზე მეტი თანხა."
            return
        }

        onSave(Expense(title: cleanTitle, amount: amount, category: category, date: date))
        dismiss()
    }
}

struct ExpenseRow: View {
    let expense: Expense

    private var formattedDate: String {
        expense.date.formatted(.dateTime.day().month(.wide).locale(Locale(identifier: "ka_GE")))
    }

    private var iconName: String {
        switch expense.category {
        case "საკვები": return "fork.knife"
        case "ტრანსპორტი": return "bus"
        case "გართობა": return "film"
        default: return "creditcard"
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 44, height: 44)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 5) {
                Text(expense.title).font(.headline)
                Text("\(expense.category) · \(formattedDate)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(String(format: "%.2f ₾", expense.amount))
                .font(.headline)
                .fontWeight(.semibold)
        }
        .padding(16)
    }
}
