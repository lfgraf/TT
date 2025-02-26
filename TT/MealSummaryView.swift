import SwiftUI

struct MealSummaryView: View {
    // The meal we're summarizing
    let meal: Meal
    
    // Environment variable to dismiss this view when needed
    @Environment(\.presentationMode) var presentationMode
    
    // State to track the user's notes as they edit
    @State private var notes: String
    
    // State to track the mindfulness rating
    @State private var mindfulnessRating: Int = 3
    
    // Initialize with the provided meal and copy its notes
    init(meal: Meal) {
        self.meal = meal
        // Use _notes to initialize the State property
        self._notes = State(initialValue: meal.notes)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header section with meal time and duration
                HStack {
                    Text("Meal Summary")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(formatDate(meal.startTime))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let endTime = meal.endTime {
                            Text("Duration: \(formatDuration(from: meal.startTime, to: endTime))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.bottom)
                
                // Conversation highlights section - shows excerpts from the meal conversation
                Text("Conversation Highlights")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                if meal.conversationLog.isEmpty {
                    Text("No conversation recorded for this meal.")
                        .italic()
                        .foregroundColor(.secondary)
                } else {
                    // Show up to 5 messages from the conversation
                    ForEach(meal.conversationLog.prefix(5)) { message in
                        HStack(alignment: .top) {
                            Image(systemName: message.isFromUser ? "person.circle.fill" : "bubble.left.fill")
                                .foregroundColor(message.isFromUser ? .blue : .green)
                            
                            VStack(alignment: .leading) {
                                Text(message.isFromUser ? "You" : "Companion")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(message.text)
                                    .padding(.top, 1)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    if meal.conversationLog.count > 5 {
                        Text("... and \(meal.conversationLog.count - 5) more messages")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                    }
                }
                
                Divider()
                    .padding(.vertical)
                
                // Food items section - what did the user eat?
                Text("What did you eat?")
                    .font(.headline)
                
                FoodTagEditor(meal: meal)
                    .padding(.vertical)
                
                // Notes section - user's reflections on the meal
                Text("Meal Notes")
                    .font(.headline)
                
                TextEditor(text: $notes)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                
                // Mindfulness rating - how present was the user during the meal?
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mindfulness Rating")
                        .font(.headline)
                    
                    Text("How present were you during this meal?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Star rating system
                    HStack {
                        ForEach(1...5, id: \.self) { value in
                            Image(systemName: value <= mindfulnessRating ? "star.fill" : "star")
                                .foregroundColor(value <= mindfulnessRating ? .yellow : .gray)
                                .font(.system(size: 24))
                                .onTapGesture {
                                    mindfulnessRating = value
                                }
                        }
                    }
                }
                .padding(.top)
                
                // Save button
                Button(action: saveAndDismiss) {
                    Text("Save Summary")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue)
                        )
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: Button("Done") {
            saveAndDismiss()
        })
    }
    
    // Save the meal data and dismiss the view
    private func saveAndDismiss() {
        meal.notes = self.notes
        // In a full implementation, you'd also save the mindfulness rating
        presentationMode.wrappedValue.dismiss()
    }
    
    // Format the meal date for display
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

// Helper view for editing food items
struct FoodTagEditor: View {
    @ObservedObject var meal: Meal
    @State private var newItem: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            // Display existing food tags in a horizontal scrollable list
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(meal.foodItems, id: \.self) { item in
                        FoodTag(text: item) {
                            // Remove the food item when the delete button is tapped
                            if let index = meal.foodItems.firstIndex(of: item) {
                                meal.foodItems.remove(at: index)
                            }
                        }
                    }
                }
            }
            
            // Input for adding new food items
            HStack {
                TextField("Add food item...", text: $newItem)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: addFoodItem) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
                .disabled(newItem.isEmpty)
            }
        }
    }
    
    // Add a new food item to the meal
    private func addFoodItem() {
        let trimmed = newItem.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !meal.foodItems.contains(trimmed) {
            meal.foodItems.append(trimmed)
            newItem = ""
        }
    }
}

// Visual component for displaying food items as tags
struct FoodTag: View {
    let text: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.subheadline)
                .padding(.leading, 8)
                .padding(.vertical, 5)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
            .padding(.trailing, 8)
        }
        .background(
            Capsule()
                .fill(Color(.systemGray5))
        )
    }
}
