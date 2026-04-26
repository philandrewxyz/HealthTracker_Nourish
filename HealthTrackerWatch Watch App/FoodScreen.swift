import SwiftUI

struct FoodScreen: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Food Intake")
                .font(.system(size: 16, weight: .bold))
                .padding(.top, 20)

                FoodControlsView()
            }
        }
    }

