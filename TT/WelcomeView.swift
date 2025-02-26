import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var mealManager: MealManager
    @State private var selectedCompanionIndex = 0
    
    var body: some View {
        VStack(spacing: 30) {
            // App title
            Text("TableTalk")
                .font(.system(size: 42, weight: .bold))
            
            Text("Your mindful mealtime companion")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Companion selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Choose your companion:")
                    .font(.headline)
                
                Picker("Select Companion", selection: $selectedCompanionIndex) {
                    ForEach(0..<Companion.allCompanions.count, id: \.self) { index in
                        Text(Companion.allCompanions[index].name).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: selectedCompanionIndex) { newValue in
                    mealManager.selectedCompanion = Companion.allCompanions[newValue]
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            
            Spacer()
            
            // Start meal button
            Button(action: {
                mealManager.startMeal()
            }) {
                Text("Start Meal")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)  // Make the button expand horizontally
                    .padding()                    // Add internal padding
                    .background(                  // Add a blue background with rounded corners
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                    )
            }
            .padding(.horizontal)                 // Add horizontal padding around the button
            
            Spacer()
        }
        .padding()  // Add padding around the whole VStack
    }
}
