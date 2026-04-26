import SwiftUI

struct WaterScreen: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Water Intake")
                .font(.system(size: 16, weight: .bold))
                .padding(.top, 20)

            WaterControlsView()
        }
    }
}
