import SwiftUI

// Visual component for displaying a conversation message
struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            // Position user messages on the right, companion messages on the left
            if message.isFromUser {
                Spacer()
            }
            
            // The message bubble
            Text(message.text)
                .padding(12)
                .background(message.isFromUser ? Color.blue : Color(.systemGray5))
                .foregroundColor(message.isFromUser ? .white : .primary)
                .cornerRadius(16)
                .frame(maxWidth: 280, alignment: message.isFromUser ? .trailing : .leading)
            
            if !message.isFromUser {
                Spacer()
            }
        }
    }
}
