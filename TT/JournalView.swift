import SwiftUI

struct JournalView: View {
    @EnvironmentObject var mealManager: MealManager
    @State private var selectedMeal: Meal?
    @State private var showMealDetail = false
    
    var body: some View {
        Group {
            if mealManager.pastMeals.isEmpty {
                // Empty state - shown when there are no past meals
                VStack(spacing: 20) {
                    Image(systemName: "book.closed")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                    
                    Text("No meal records yet")
                        .font(.headline)
                    
                    Text("Your meal journal will show here after you complete your first meal with TableTalk.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                .padding()
            } else {
                // List of past meals
                List {
                    ForEach(mealManager.pastMeals) { meal in
                        Button(action: {
                            // Show the meal details when a meal is tapped
                            selectedMeal = meal
                            showMealDetail = true
                        }) {
                            MealJournalRow(meal: meal)
                        }
                    }
                    .onDelete(perform: deleteMeal)
                }
            }
        }
        .navigationTitle("Meal Journal")
        .sheet(isPresented: $showMealDetail) {
            // Show the meal summary when a meal is selected
            if let meal = selectedMeal {
                NavigationView {
                    MealSummaryView(meal: meal)
                }
            }
        }
    }
    
    // Delete a meal from the journal
    private func deleteMeal(at offsets: IndexSet) {
        mealManager.pastMeals.remove(atOffsets: offsets)
    }
}

// Row component for displaying a meal in the journal
struct MealJournalRow: View {
    let meal: Meal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(formatDate(meal.startTime))
                    .font(.headline)
                
                Spacer()
                
                if let endTime = meal.endTime {
                    Text("\(formatDuration(from: meal.startTime, to: endTime))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !meal.foodItems.isEmpty {
                Text(meal.foodItems.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            if !meal.notes.isEmpty {
                Text(meal.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
    
    // Format the date for display
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Calculate and format the meal duration
    private func formatDuration(from startDate: Date, to endDate: Date) -> String {
        let duration = endDate.timeIntervalSince(startDate)
        let minutes = Int(duration / 60)
        
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours) hr \(remainingMinutes) min"
        }
    }
}
