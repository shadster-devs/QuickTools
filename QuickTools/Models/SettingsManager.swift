//
//  SettingsManager.swift
//  QuickTools
//
//  Created by Shakthi M on 29/07/25.
//

import SwiftUI

// MARK: - Tool Definition
struct DevTool: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let icon: String
    let description: String
    var isEnabled: Bool
    var order: Int
    
    static let allTools: [DevTool] = [
        DevTool(id: "json", name: "JSON", icon: "curlybraces", description: "Validate and format JSON", isEnabled: true, order: 0),
        DevTool(id: "regex", name: "Regex", icon: "textformat.abc", description: "Test regular expressions", isEnabled: true, order: 1),
        DevTool(id: "timestamp", name: "Timestamp", icon: "clock", description: "Convert Unix timestamps", isEnabled: true, order: 2),
        DevTool(id: "url", name: "URL Encoder", icon: "link", description: "Encode/decode URLs", isEnabled: true, order: 3),
        DevTool(id: "base64", name: "Base64", icon: "doc.text.magnifyingglass", description: "Encode/decode Base64", isEnabled: true, order: 4),
        DevTool(id: "hash", name: "Hash", icon: "number.square", description: "Generate MD5, SHA hashes", isEnabled: true, order: 5),
        DevTool(id: "uuid", name: "UUID", icon: "doc.text.below.ecg", description: "Generate unique identifiers", isEnabled: true, order: 6),
        DevTool(id: "color", name: "Color Picker", icon: "paintpalette.fill", description: "Pick and convert colors", isEnabled: true, order: 7),
        DevTool(id: "image", name: "Image Converter", icon: "photo", description: "Convert image formats", isEnabled: true, order: 8),
        DevTool(id: "text-diff", name: "Text Diff", icon: "doc.text.magnifyingglass", description: "Compare text differences", isEnabled: true, order: 9),
        DevTool(id: "qr", name: "QR Generator", icon: "qrcode", description: "Generate QR codes", isEnabled: true, order: 10),
        DevTool(id: "snippet", name: "Snippet Store", icon: "chevron.left.forwardslash.chevron.right", description: "Store and manage code snippets", isEnabled: true, order: 11)
    ]
}

// MARK: - Theme Definition
enum AppTheme: String, CaseIterable, Codable {
    case auto = "auto"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .auto: return "Auto"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .auto: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - Settings Manager
class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var enabledTools: [DevTool] = []
    @Published var theme: AppTheme = .auto
    @Published var windowSize: CGSize = CGSize(width: AppConstants.UI.defaultWindowWidth, height: AppConstants.UI.defaultWindowHeight)
    @Published var showToolDescriptions: Bool = true
    
    private let userDefaults = UserDefaults.standard
    
    private init() {
        loadSettings()
    }
    
    var sortedEnabledTools: [DevTool] {
        enabledTools.filter { $0.isEnabled }.sorted { $0.order < $1.order }
    }
    
    func loadSettings() {
        // Load tools
        if let toolsData = userDefaults.data(forKey: AppConstants.UserDefaultsKeys.enabledTools),
           let tools = try? JSONDecoder().decode([DevTool].self, from: toolsData) {
            enabledTools = tools
        } else {
            enabledTools = DevTool.allTools
        }
        
        // Load theme
        if let themeString = userDefaults.string(forKey: AppConstants.UserDefaultsKeys.appTheme),
           let savedTheme = AppTheme(rawValue: themeString) {
            theme = savedTheme
        }
        
        // Load window size
        let width = userDefaults.double(forKey: AppConstants.UserDefaultsKeys.windowWidth)
        let height = userDefaults.double(forKey: AppConstants.UserDefaultsKeys.windowHeight)
        if width > 0 && height > 0 {
            windowSize = CGSize(width: width, height: height)
        }
        
        // Load show descriptions
        showToolDescriptions = userDefaults.bool(forKey: AppConstants.UserDefaultsKeys.showToolDescriptions)
    }
    
    func saveSettings() {
        // Save tools
        if let toolsData = try? JSONEncoder().encode(enabledTools) {
            userDefaults.set(toolsData, forKey: AppConstants.UserDefaultsKeys.enabledTools)
        }
        
        // Save theme
        userDefaults.set(theme.rawValue, forKey: AppConstants.UserDefaultsKeys.appTheme)
        
        // Save window size
        userDefaults.set(windowSize.width, forKey: AppConstants.UserDefaultsKeys.windowWidth)
        userDefaults.set(windowSize.height, forKey: AppConstants.UserDefaultsKeys.windowHeight)
        
        // Save show descriptions
        userDefaults.set(showToolDescriptions, forKey: AppConstants.UserDefaultsKeys.showToolDescriptions)
        
        userDefaults.synchronize()
    }
    
    func toggleTool(_ toolId: String) {
        if let index = enabledTools.firstIndex(where: { $0.id == toolId }) {
            enabledTools[index].isEnabled.toggle()
            saveSettings()
        }
    }
    
    func moveTool(from sourceIndices: IndexSet, to destinationIndex: Int) {
        var sortedTools = sortedEnabledTools
        sortedTools.move(fromOffsets: sourceIndices, toOffset: destinationIndex)
        
        // Update order in enabledTools
        for (index, tool) in sortedTools.enumerated() {
            if let originalIndex = enabledTools.firstIndex(where: { $0.id == tool.id }) {
                enabledTools[originalIndex].order = index
            }
        }
        
        saveSettings()
    }
    
    func resetToDefaults() {
        enabledTools = DevTool.allTools
        theme = .auto
        windowSize = CGSize(width: AppConstants.UI.defaultWindowWidth, height: AppConstants.UI.defaultWindowHeight)
        showToolDescriptions = true
        saveSettings()
    }
    
    func getViewForTool(_ toolId: String) -> AnyView {
        switch toolId {
        case "json":
            return AnyView(JSONValidatorView())
        case "regex":
            return AnyView(RegexTesterView())
        case "timestamp":
            return AnyView(TimestampConverterView())
        case "url":
            return AnyView(URLEncoderView())
        case "base64":
            return AnyView(Base64EncoderView())
        case "hash":
            return AnyView(HashGeneratorView())
        case "uuid":
            return AnyView(UUIDGeneratorView())
        case "color":
            return AnyView(ColorPickerView())
        case "image":
            return AnyView(ImageConverterView())
        case "text-diff":
            return AnyView(TextDiffView())
        case "qr":
            return AnyView(QRGeneratorView())
        case "snippet":
            return AnyView(SnippetStoreView())
        default:
            return AnyView(Text("Tool not found"))
        }
    }
} 
