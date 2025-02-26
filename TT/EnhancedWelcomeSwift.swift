//
//  EnhancedWelcomeSwift.swift
//  TT
//
//  Created by Raf V. on 25/02/25.
//

import SwiftUI

struct EnhancedWelcomeView: View {
    @EnvironmentObject var mealManager: MealManager
    @State private var selectedCompanionIndex = 0
    @State private var showSettings = false
    
    var body: some View {
        VStack(spacing: 30) {
            // App title and logo
            Text("TableTalk")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Your mindful mealtime companion")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Enhanced companion selection - using buttons instead of a picker
            // This provides a more visual and engaging selection experience
            VStack(alignment: .leading, spacing: 10) {
                Text("Choose your companion:")
                    .font(.headline)
                
                // We loop through all companions and create a button for each
                ForEach(0..<Companion.allCompanions.count, id: \.self) { index in
                    Button(action: {
                        // When tapped, we update the selected companion
                        selectedCompanionIndex = index
                        mealManager.selectedCompanion = Companion.allCompanions[index]
                    }) {
                        HStack {
                            // Companion avatar/icon
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                // Highlight the selected companion
                                .foregroundColor(selectedCompanionIndex == index ? .blue : .gray)
                            
                            // Companion name and selection hint
                            VStack(alignment: .leading) {
                                Text(Companion.allCompanions[index].name)
                                    .font(.headline)
                                    .foregroundColor(selectedCompanionIndex == index ? .primary : .secondary)
                                
                                Text("Tap to select")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Checkmark for the selected companion
                            if selectedCompanionIndex == index {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                // Highlight the selected companion's background
                                .fill(selectedCompanionIndex == index ? Color(.systemGray5) : Color(.systemGray6))
                        )
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Start meal button
            Button(action: {
                mealManager.startMeal()
            }) {
                Text("Start Meal")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                    )
            }
            .padding(.horizontal)
            
            // Navigation options
            HStack {
                // Journal button with NavigationLink
                NavigationLink(destination: JournalView()) {
                    Text("Meal Journal")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                }
                
                // Settings button that shows a sheet
                Button(action: {
                    showSettings = true
                }) {
                    Text("Settings")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .navigationBarHidden(true)
        .sheet(isPresented: $showSettings) {
            // Show settings as a modal sheet when the settings button is tapped
            NavigationView {
                SettingsView()
            }
        }
    }
}
