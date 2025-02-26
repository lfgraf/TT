import SwiftUI

// Manages the overall state of meal sessions
class MealManager: ObservableObject {
    // Current active meal (nil when not in a session)
    @Published var currentMeal: Meal?
    
    // History of past meals
    @Published var pastMeals: [Meal] = []
    
    // Flag indicating if we're in an active meal session
    @Published var isInMealSession = false
    
    // Currently selected AI companion
    @Published var selectedCompanion = Companion.defaultCompanion
    
    // Starts a new meal session
    func startMeal() {
        currentMeal = Meal(startTime: Date())
        isInMealSession = true
    }
    
    // Ends the current meal session and archives it
    func endMeal() {
        if let meal = currentMeal {
            meal.endTime = Date()
            pastMeals.append(meal)
            
            // Notify interested components that a meal has ended
            NotificationCenter.default.post(
                name: .mealEnded,
                object: meal
            )
            
            currentMeal = nil
            isInMealSession = false
        }
    }
}

// Represents a single meal session with its conversation
class Meal: Identifiable, ObservableObject {
    let id = UUID()
    let startTime: Date
    var endTime: Date?
    @Published var notes: String = ""
    @Published var foodItems: [String] = []
    @Published var conversationLog: [Message] = []
    
    init(startTime: Date) {
        self.startTime = startTime
    }
}

// Represents a single message in the conversation
struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp: Date
}

// Represents an AI companion character
struct Companion {
    let name: String
    let voiceIdentifier: String
    let greeting: String
    
    // The default companion
    static let defaultCompanion = Companion(
        name: "Sam",
        voiceIdentifier: "com.apple.voice.compact.en-US.Samantha",
        greeting: "Hello! I'm Sam, your TableTalk companion. What are you having today?"
    )
    
    // All available companion options
    static let allCompanions = [
        defaultCompanion,
        Companion(
            name: "Alex",
            voiceIdentifier: "com.apple.voice.compact.en-US.Alex",
            greeting: "Hi there! I'm Alex. Ready to enjoy your meal together?"
        ),
        Companion(
            name: "Jamie",
            voiceIdentifier: "com.apple.voice.compact.en-GB.Daniel",
            greeting: "Lovely to meet you! I'm Jamie. What delicious food are we enjoying today?"
        )
    ]
}

// Custom notification names used throughout the app
extension Notification.Name {
    static let mealEnded = Notification.Name("mealEnded")
}
