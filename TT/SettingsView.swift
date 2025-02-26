//
//  SettingsView.swift
//  TT
//
//  Created by Raf V. on 25/02/25.
//

import SwiftUI

struct SettingsView: View {
    // App settings stored in UserDefaults for persistence between app launches
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("reminderEnabled") private var reminderEnabled: Bool = false
    @AppStorage("reminderTime") private var reminderTime = Date()
    
    var body: some View {
        Form {
            // User profile section
            Section(header: Text("Profile")) {
                TextField("Your Name", text: $userName)
            }
            
            // Meal reminders section
            Section(header: Text("Meal Reminders")) {
                Toggle("Enable Reminders", isOn: $reminderEnabled)
                
                if reminderEnabled {
                    DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                }
            }
            
            // About section
            Section(header: Text("About TableTalk")) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("TableTalk helps you be more mindful during meals and reduces the feeling of eating alone.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Taking time to enjoy your meals can improve digestion, satisfaction, and overall well-being.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Version 1.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 10)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationBarTitle("Settings")
    }
}
