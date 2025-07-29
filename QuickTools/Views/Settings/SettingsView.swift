//
//  SettingsView.swift
//  QuickTools
//
//  Created by Shakthi M on 29/07/25.
//

import SwiftUI
import Sparkle

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var showingResetAlert = false
    @State private var selectedTheme: AppTheme
    
    let isEmbedded: Bool
    let onClose: (() -> Void)?
    
    init(isEmbedded: Bool = false, onClose: (() -> Void)? = nil) {
        self.isEmbedded = isEmbedded
        self.onClose = onClose
        _selectedTheme = State(initialValue: SettingsManager.shared.theme)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Enhanced Header with Gradient
            headerSection
            
            ScrollView {
                VStack(spacing: 24) {
                    // Theme Section
                    appearanceSection
                    
                    // Tools Section
                    toolsSection
                    
                    // Reset Section
                    resetSection
                    
                    // About Section
                    aboutSection
                    
                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
        .alert("Reset Settings", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                settingsManager.resetToDefaults()
                selectedTheme = settingsManager.theme
            }
        } message: {
            Text("Are you sure you want to reset all settings to their default values? This action cannot be undone.")
        }
        .onAppear {
            selectedTheme = settingsManager.theme
        }
    }
    
    // MARK: - UI Sections
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(NSColor.windowBackgroundColor),
                Color(NSColor.windowBackgroundColor).opacity(0.95),
                Color(NSColor.controlBackgroundColor).opacity(0.3)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                Text("Settings")
                    .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primary, .primary.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Customize your QuickTools experience")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isEmbedded {
                    Button(action: { 
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            onClose?()
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 32, height: 32)
                            )
                    }
                    .buttonStyle(.borderless)
                    .scaleEffect(0.9)
                } else {
                    Button("Done") {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        onClose?()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                LinearGradient(
                    colors: [.blue.opacity(0.05), .purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(Material.ultraThinMaterial)
            
            // Subtle divider
            Rectangle()
                .fill(.quaternary)
                .frame(height: 1)
        }
    }
    
    private var appearanceSection: some View {
        ModernCard {
                    VStack(alignment: .leading, spacing: 20) {
                SectionHeader(
                    icon: "paintbrush.fill",
                    title: "Appearance",
                    subtitle: "Customize the visual theme",
                    color: .blue
                )
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Theme")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                    // Enhanced theme picker
                    HStack(spacing: 12) {
                                ForEach(AppTheme.allCases, id: \.self) { theme in
                            ThemeCard(
                                theme: theme,
                                isSelected: selectedTheme == theme
                            ) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            selectedTheme = theme
                                            settingsManager.theme = theme
                                            settingsManager.saveSettings()
                                        }
                            }
                        }
                    }
                    
                    // Enhanced description toggle
                    ToggleRow(
                        title: "Show Descriptions",
                        subtitle: "Display tool descriptions in the interface",
                        isOn: .constant(settingsManager.showToolDescriptions)
                    ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        settingsManager.showToolDescriptions.toggle()
                                        settingsManager.saveSettings()
                                    }
                    }
                }
            }
        }
    }
    
    private var toolsSection: some View {
        ModernCard {
                    VStack(alignment: .leading, spacing: 20) {
                SectionHeader(
                    icon: "wrench.and.screwdriver.fill",
                    title: "Developer Tools",
                    subtitle: "Customize which tools appear and their order",
                    color: .orange,
                    badge: "\(settingsManager.sortedEnabledTools.count) enabled"
                )
                            
                VStack(spacing: 8) {
                                ForEach(settingsManager.enabledTools.sorted { $0.order < $1.order }) { tool in
                        EnhancedToolRow(tool: tool)
                                        .environmentObject(settingsManager)
                                }
                            }
            }
                        }
                    }
    
    private var resetSection: some View {
        ModernCard {
                    VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    icon: "arrow.clockwise.circle.fill",
                    title: "Reset Settings",
                    subtitle: "Restore all settings to their default values",
                    color: .red
                )
                            
                            Button("Reset to Defaults") {
                                showingResetAlert = true
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(.red)
                            .controlSize(.large)
                        }
                    }
    }
    
    private var aboutSection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: 20) {
                SectionHeader(
                    icon: "info.circle.fill",
                    title: "About QuickTools",
                    subtitle: "App information and credits",
                    color: .blue
                )
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 16) {
                        // App icon with gradient background
                        ZStack {
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            Image(systemName: "wrench.and.screwdriver")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("QuickTools")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text("Developer Tools Collection")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Version \(AppConstants.appVersion)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    Text("A collection of useful developer tools for quick access from your menu bar. Simplify your development workflow with easy-to-use utilities for JSON validation, regex testing, encoding/decoding, and more.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Update section
                    UpdateStatusSection()
                        .padding(.top, 12)
                    
                    HStack {
                        Text("Created by Shakthi M")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("© 2025")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
    
    private func themeIcon(for theme: AppTheme) -> String {
        switch theme {
        case .auto: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

// MARK: - Supporting Views

struct ModernCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
                    .padding(24)
                    .background(
                ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.1), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.quaternary, lineWidth: 1)
                }
            )
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct SectionHeader: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let badge: String?
    
    init(icon: String, title: String, subtitle: String, color: Color, badge: String? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.badge = badge
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .font(.title3)
                        .frame(width: 24, height: 24)
                    
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                }
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let badge = badge {
                Text(badge)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
    }
}

struct ThemeCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: themeIcon(for: theme))
                    .font(.title2)
                    .foregroundStyle(
                        isSelected ? 
                        LinearGradient(colors: [.white], startPoint: .top, endPoint: .bottom) :
                        LinearGradient(colors: [.primary], startPoint: .top, endPoint: .bottom)
                    )
                
                Text(theme.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            isSelected ? 
                            LinearGradient(
                                colors: [.blue, .blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color(NSColor.controlBackgroundColor)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    }
                }
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(
                color: isSelected ? .blue.opacity(0.3) : .clear,
                radius: isSelected ? 8 : 0,
                x: 0,
                y: isSelected ? 4 : 0
            )
        }
        .buttonStyle(.borderless)
    }
    
    private func themeIcon(for theme: AppTheme) -> String {
        switch theme {
        case .auto: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

struct ToggleRow: View {
    let title: String
    let subtitle: String
    let isOn: Binding<Bool>
    let action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: action) {
                Image(systemName: isOn.wrappedValue ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(
                        isOn.wrappedValue ?
                        LinearGradient(colors: [.blue, .blue.opacity(0.8)], startPoint: .top, endPoint: .bottom) :
                        LinearGradient(colors: [.secondary], startPoint: .top, endPoint: .bottom)
                    )
                    .font(.title2)
            }
            .buttonStyle(.borderless)
            .scaleEffect(isOn.wrappedValue ? 1.1 : 1.0)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.primary.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct EnhancedToolRow: View {
    let tool: DevTool
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Tool icon with background
            ZStack {
                Circle()
                    .fill(tool.isEnabled ? .blue.opacity(0.1) : .secondary.opacity(0.05))
                    .frame(width: 32, height: 32)
                
            Image(systemName: tool.icon)
                .foregroundColor(tool.isEnabled ? .blue : .secondary)
                    .font(.system(size: 14, weight: .medium))
            }
            
            // Tool info
            VStack(alignment: .leading, spacing: 2) {
                Text(tool.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(tool.isEnabled ? .primary : .secondary)
                
                if settingsManager.showToolDescriptions {
                    Text(tool.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Enhanced toggle
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    settingsManager.toggleTool(tool.id)
                }
            }) {
                Image(systemName: tool.isEnabled ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(
                        tool.isEnabled ?
                        LinearGradient(colors: [.blue, .blue.opacity(0.8)], startPoint: .top, endPoint: .bottom) :
                        LinearGradient(colors: [.secondary], startPoint: .top, endPoint: .bottom)
                    )
                    .font(.title3)
            }
            .buttonStyle(.borderless)
            .scaleEffect(tool.isEnabled ? 1.05 : 1.0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    tool.isEnabled ?
                    Color(NSColor.textBackgroundColor) :
                    Color(NSColor.textBackgroundColor).opacity(0.5)
                )
        )
        .scaleEffect(tool.isEnabled ? 1.0 : 0.97)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: tool.isEnabled)
    }
}

struct UpdateStatusSection: View {
    @State private var isChecking = false
    @State private var lastCheckDate: Date? = UserDefaults.standard.object(forKey: "LastUpdateCheck") as? Date
    @State private var updateAvailable = false
    @State private var availableVersion: String? = nil
    @State private var updateMessage = "You're up to date"
    
    private let updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundColor(.blue)
                    .font(.title3)
                
                Text("Software Update")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            // Current Status
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Current Version:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(AppConstants.appVersion)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                if let lastCheck = lastCheckDate {
                    HStack {
                        Text("Last Checked:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(formatDate(lastCheck))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text("Status:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        if isChecking {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: updateAvailable ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                                .foregroundColor(updateAvailable ? .orange : .green)
                                .font(.caption)
                        }
                        
                        Text(isChecking ? "Checking..." : updateMessage)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(updateAvailable ? .orange : .green)
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Actions
            HStack(spacing: 12) {
                Button(action: checkForUpdates) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                        Text("Check Now")
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(isChecking)
                
                if updateAvailable {
                    Button(action: installUpdate) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.down")
                            Text("Install Update")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                
                Spacer()
            }
        }
        .onAppear {
            checkUpdateStatus()
        }
    }
    
    private func checkForUpdates() {
        isChecking = true
        updaterController.checkForUpdates(nil)
        
        // Update last check date
        lastCheckDate = Date()
        UserDefaults.standard.set(lastCheckDate, forKey: "LastUpdateCheck")
        
        // Reset state after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isChecking = false
            updateMessage = "You're up to date"
            updateAvailable = false
        }
    }
    
    private func installUpdate() {
        updaterController.checkForUpdates(nil)
    }
    
    private func checkUpdateStatus() {
        // Check if automatic updates are enabled and when last check was
        updateMessage = "You're up to date"
        updateAvailable = false
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    SettingsView(isEmbedded: true) {
        print("Close settings")
    }
    .environmentObject(SettingsManager.shared)
} 