import SwiftUI

struct ContentView: View {
    @EnvironmentObject var mealManager: MealManager
    @State private var showMealSummary = false
    @State private var completedMeal: Meal?
    
    var body: some View {
        NavigationView {
            if mealManager.isInMealSession {
                // Active meal session
                MealSessionView()
                    .environmentObject(mealManager)
                    .onReceive(NotificationCenter.default.publisher(for: .mealEnded)) { notification in
                        if let meal = notification.object as? Meal {
                            completedMeal = meal
                            showMealSummary = true
                        }
                    }
                    .sheet(isPresented: $showMealSummary) {
                        // Show the meal summary sheet when a meal ends
                        if let meal = completedMeal {
                            NavigationView {
                                MealSummaryView(meal: meal)
                            }
                        }
                    }
            } else {
                // Welcome screen with enhanced UI
                EnhancedWelcomeView()
            }
        }
    }
}
