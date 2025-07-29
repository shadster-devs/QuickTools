//
//  QuickToolsApp.swift
//  QuickTools
//
//  Created by Shakthi M on 29/07/25.
//

import SwiftUI
import Sparkle

@main
struct QuickToolsApp: App {
    @StateObject private var settingsManager = SettingsManager.shared
    private let updaterController: SPUStandardUpdaterController
    
    init() {
        // Initialize Sparkle updater
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }
    
    var body: some Scene {
        MenuBarExtra("QuickTools", systemImage: "wrench.and.screwdriver") {
            ContentView()
                .environmentObject(settingsManager)
        }
        .menuBarExtraStyle(.window)
    }
}
