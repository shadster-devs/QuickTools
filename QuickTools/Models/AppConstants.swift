//
//  AppConstants.swift
//  QuickTools
//
//  Created by Shakthi M on 29/07/25.
//

import SwiftUI

enum AppConstants {
    // MARK: - App Info
    static let appName = "QuickTools"
    static let appVersion = "1.2.1"
    static let appDescription = "Essential developer tools in your menu bar"
    
    // MARK: - UI Constants
    enum UI {
        static let defaultWindowWidth: CGFloat = 450
        static let defaultWindowHeight: CGFloat = 500
        static let toolCardHeight: CGFloat = 100
        static let cornerRadius: CGFloat = 12
        static let smallCornerRadius: CGFloat = 6
        static let standardPadding: CGFloat = 16
        static let smallPadding: CGFloat = 8
    }
    
    // MARK: - Limits
    enum Limits {
        static let maxHistoryItems = 50
        static let maxColorHistory = 30
        static let maxUUIDHistory = 50
        static let maxBatchSize = 10
    }
    
    // MARK: - UserDefaults Keys
    enum UserDefaultsKeys {
        static let enabledTools = "enabledTools"
        static let appTheme = "appTheme"
        static let windowWidth = "windowWidth"
        static let windowHeight = "windowHeight"
        static let showToolDescriptions = "showToolDescriptions"
        static let colorPickerHistory = "ColorPickerHistory"
    }
    
    // MARK: - Animation Durations
    enum Animation {
        static let standard: Double = 0.3
        static let quick: Double = 0.2
        static let feedback: Double = 1.5
    }
} 