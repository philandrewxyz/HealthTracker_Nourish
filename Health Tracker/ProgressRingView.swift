import SwiftUI

struct ProgressRingView: View {
    var progress: Double
    var color: Color
    var icon: String
    var current: Double
    var goal: Double
    var unit: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: min(1.0, progress))
                    .stroke(color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(), value: progress)
                
                VStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                    Text("\(Int((progress.isNaN || progress.isInfinite) ? 0 : progress * 100))%")
                        .font(.headline.bold())
                }
            }
            .frame(width: 120, height: 120)
            
            VStack {
                Text("\(Int(current)) / \(Int(goal))")
                    .font(.subheadline.bold())
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
