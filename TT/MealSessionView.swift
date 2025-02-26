import SwiftUI

struct MealSessionView: View {
    @EnvironmentObject var mealManager: MealManager
    @StateObject private var speechRecognizer = SpeechRecognitionManager()
    @StateObject private var speechSynthesizer = SpeechSynthesizer()
    @StateObject private var conversationManager = ConversationManager()
    
    @State private var showingTextInput = false
    @State private var textInput = ""
    @State private var isListening = false
    
    var body: some View {
        VStack {
            // Companion header
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)
                
                Text(mealManager.selectedCompanion.name)
                    .font(.title2)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button(action: {
                    mealManager.endMeal()
                }) {
                    Text("End Meal")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            
            // Conversation area
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(conversationManager.messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            // Input area
            VStack(spacing: 12) {
                // Text input (shown conditionally)
                if showingTextInput {
                    HStack {
                        TextField("Type your response...", text: $textInput)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        Button(action: sendTextMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        }
                        .disabled(textInput.isEmpty)
                    }
                }
                
                // Voice controls
                HStack(spacing: 20) {
                    // Toggle text input
                    Button(action: {
                        showingTextInput.toggle()
                    }) {
                        Image(systemName: showingTextInput ? "keyboard.chevron.compact.down" : "keyboard")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                    }
                    
                    // Voice recording button
                    Button(action: toggleListening) {
                        Image(systemName: isListening ? "waveform.circle.fill" : "mic.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(isListening ? .red : .blue)
                            .overlay(
                                Group {
                                    if isListening {
                                        Circle()
                                            .stroke(Color.red, lineWidth: 2)
                                            .frame(width: 70, height: 70)
                                    }
                                }
                            )
                    }
                    
                    // Ask prompt button
                    Button(action: askPrompt) {
                        Image(systemName: "text.bubble")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            // Request speech recognition permissions when view appears
            speechRecognizer.requestAuthorization()
            
            // Start with companion greeting
            let greeting = mealManager.selectedCompanion.greeting
            conversationManager.addCompanionMessage(greeting)
            speechSynthesizer.speak(text: greeting, with: mealManager.selectedCompanion.voiceIdentifier)
        }
    }
    
    // MARK: - Actions
    
    // Toggle between listening and not listening
    private func toggleListening() {
        if isListening {
            speechRecognizer.stopListening()
            isListening = false
            
            // Process any recognized text
            if !speechRecognizer.recognizedText.isEmpty {
                processUserInput(speechRecognizer.recognizedText)
                speechRecognizer.recognizedText = ""
            }
        } else {
            speechRecognizer.startListening()
            isListening = true
        }
    }
    
    // Send a message typed in the text field
    private func sendTextMessage() {
        guard !textInput.isEmpty else { return }
        processUserInput(textInput)
        textInput = ""
    }
    
    // Have the companion ask a random prompt
    private func askPrompt() {
        let prompt = conversationManager.getNextPrompt()
        conversationManager.addCompanionMessage(prompt)
        speechSynthesizer.speak(text: prompt, with: mealManager.selectedCompanion.voiceIdentifier)
    }
    
    // Process user input (from either voice or text)
    private func processUserInput(_ input: String) {
        // Add user message to conversation
        conversationManager.addUserMessage(input)
        
        // Generate and speak response (after a small delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let response = conversationManager.generateResponse(to: input)
            conversationManager.addCompanionMessage(response)
            speechSynthesizer.speak(text: response, with: mealManager.selectedCompanion.voiceIdentifier)
            
            // Save conversation to current meal
            if let currentMeal = mealManager.currentMeal {
                currentMeal.conversationLog = conversationManager.messages
            }
        }
    }
}
