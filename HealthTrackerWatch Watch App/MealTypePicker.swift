import SwiftUI

struct MealTypePickerView: View {
    @Binding var consumed: Double
    let dailyGoal: Double

    var body: some View {
        VStack(spacing: 10) {
            Text("Meal Type")
                .font(.headline)
                .padding(.bottom, 4)

            ForEach(MealType.allCases, id: \.self) { type in
                NavigationLink(type.rawValue) {
                    FoodControls(consumed: $consumed, dailyGoal: dailyGoal, mealType: type)
                }
                .font(.caption.bold())
                .foregroundColor(.orange)
            }
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        MealTypePickerView(consumed: .constant(800), dailyGoal: 2000)
    }
}
