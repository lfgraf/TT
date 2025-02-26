//
//  TTApp.swift
//  TT
//
//  Created by Raf V. on 25/02/25.
//
import SwiftUI

@main
struct TableTalkApp: App {
    // Create a MealManager that will persist throughout the app's lifecycle
    @StateObject private var mealManager = MealManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mealManager)
        }
    }
}
