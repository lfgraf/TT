import SwiftUI

// Manages the conversation flow between user and AI companion
class ConversationManager: ObservableObject {
    // All messages in the current conversation
    @Published var messages: [Message] = []
    
    // Predefined prompts the companion can ask
    private let prompts = [
        "How does your food taste?",
        "What's your favorite thing about this meal?",
        "Are you enjoying the flavors?",
        "Is this a recipe you make often?",
        "What's the most interesting ingredient in your meal?",
        "How does this meal make you feel?",
        "Would you try anything different next time you make this?",
        "Is there a story behind this dish?",
        "What textures are you noticing in your food?",
        "Are you eating mindfully, taking time to appreciate each bite?"
    ]
    
    // Template responses for the companion
    private let responses = [
        "That sounds delicious!",
        "I can imagine how flavorful that must be.",
        "It's interesting how food connects to our memories.",
        "Taking time to enjoy meals is so important.",
        "That's a great observation about your food.",
        "I appreciate how thoughtful you are about your meal.",
        "Mindful eating really enhances the experience, doesn't it?",
        "That's a wonderful way to describe those flavors."
    ]
    
    // Follow-up questions the companion can ask
    private let followUps = [
        "Have you tried any new recipes lately?",
        "What's a meal you're looking forward to making soon?",
        "Do you notice how your body feels while eating?",
        "What's your favorite cuisine?",
        "Do you prefer eating alone or with others?",
        "What's the most memorable meal you've had recently?"
    ]
    
    // Add a message from the user to the conversation
    func addUserMessage(_ text: String) {
        let message = Message(text: text, isFromUser: true, timestamp: Date())
        messages.append(message)
    }
    
    // Generate a response to a user message
    func generateResponse(to userMessage: String) -> String {
        // Look for keywords in the user's message
        let userMessageLower = userMessage.lowercased()
        
        // Different responses based on sentiment detection
        if userMessageLower.contains("not good") || userMessageLower.contains("bad") || userMessageLower.contains("terrible") {
            return "I'm sorry to hear that. Maybe next time will be better!"
        }
        
        if userMessageLower.contains("delicious") || userMessageLower.contains("good") || userMessageLower.contains("tasty") {
            return "That's wonderful! Good food can really brighten your day."
        }
        
        if userMessageLower.contains("recipe") || userMessageLower.contains("cook") || userMessageLower.contains("made") {
            return "It sounds like you put effort into preparing that. Cooking can be so rewarding!"
        }
        
        // For messages without specific keywords, combine a response with a follow-up
        let randomResponse = responses.randomElement() ?? "That's interesting!"
        let randomFollowUp = followUps.randomElement() ?? "Tell me more about your meal."
        
        return "\(randomResponse) \(randomFollowUp)"
    }
    
    // Get a random prompt for the companion to ask
    func getNextPrompt() -> String {
        return prompts.randomElement() ?? "How is your meal?"
    }
    
    // Add a message from the companion to the conversation
    func addCompanionMessage(_ text: String) {
        let message = Message(text: text, isFromUser: false, timestamp: Date())
        messages.append(message)
    }
}
