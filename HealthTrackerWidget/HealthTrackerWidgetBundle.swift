import WidgetKit
import SwiftUI

@main
struct HealthTrackerWidgetBundle: WidgetBundle {
    var body: some Widget {
        HealthTrackerWidget()
        HealthTrackerWidgetControl()
    }
}
