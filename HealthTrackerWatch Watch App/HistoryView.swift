import SwiftUI

struct HistoryView: View {
    @State private var history: [DailyRecord] = []

    var foodAvg: Double {
        guard !history.isEmpty else { return 0 }
        return history.map { $0.food }.reduce(0, +) / Double(history.count)
    }

    var waterAvg: Double {
        guard !history.isEmpty else { return 0 }
        return history.map { $0.water }.reduce(0, +) / Double(history.count)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Text("7-Day Averages")
                    .font(.system(size: 14, weight: .bold))
                
                // averages box
                HStack {
                    VStack(spacing: 4) {
                        Image(systemName: "fork.knife")
                            .foregroundColor(.orange)
                        Text("\(Int(foodAvg)) kcal")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                    }
                    Spacer()
                    VStack(spacing: 4) {
                        Image(systemName: "drop.fill")
                            .foregroundColor(.blue)
                        Text("\(Int(waterAvg)) ml")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                    }
                }
                .padding(12)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)

                Divider()

                Text("Recent Days")
                    .font(.system(size: 14, weight: .bold))

                // this will list the past few days
                if history.isEmpty {
                    Text("No data yet. Check back tomorrow!")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                } else {
                    ForEach(history.reversed()) { record in
                        HStack {
                            Text(record.date, format: .dateTime.month().day())
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(record.food))")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)
                            Text("|")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                            Text("\(Int(record.water))")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            history = HistoryManager.shared.getHistory()
        }
    }
}

#Preview {
    HistoryView()
}
