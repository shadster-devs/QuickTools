//
//  ContentView.swift
//  QuickTools
//
//  Created by Shakthi M on 29/07/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var selectedTool: DevTool? = nil
    @State private var showingSettings = false
    
    var enabledTools: [DevTool] {
        settingsManager.sortedEnabledTools
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if showingSettings {
                    // Settings View
                    SettingsView(isEmbedded: true) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingSettings = false
                        }
                    }
                } else if let selectedTool = selectedTool {
                    // Individual Tool View
                    VStack(spacing: 0) {
                        // Back button header
                        HStack {
                            Button(action: {
                                withAnimation(.easeInOut(duration: AppConstants.Animation.standard)) {
                                    self.selectedTool = nil
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 12, weight: .medium))
                                    Text("Back")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.borderless)
                            
                            Spacer()
                            
                            // Tool title
                            HStack(spacing: 8) {
                                Image(systemName: selectedTool.icon)
                                    .foregroundColor(.blue)
                                Text(selectedTool.name)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            Spacer()
                            
                            // Invisible spacer for balance
                            Color.clear
                                .frame(width: 80, height: 32)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial.opacity(0.5))
                        
                        // Tool content
                        settingsManager.getViewForTool(selectedTool.id)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else if enabledTools.isEmpty {
                    // No tools enabled state
                    VStack(spacing: 20) {
                        Image(systemName: "wrench.and.screwdriver")
                            .font(.system(size: 60, weight: .ultraLight))
                            .foregroundColor(.secondary.opacity(0.6))
                        
                        VStack(spacing: 8) {
                            Text("No Tools Enabled")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("Enable developer tools in settings")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Button("Open Settings") {
                            withAnimation(.easeInOut(duration: AppConstants.Animation.standard)) {
                                showingSettings = true
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(NSColor.windowBackgroundColor))
                } else {
                    // Main Grid View
                    VStack(spacing: 16) {
                        // Header
                        VStack(spacing: 6) {
                            HStack(spacing: 10) {
                                Image(systemName: "wrench.and.screwdriver")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                Text("QuickTools")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            Text("Developer Tools Collection")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 16)
                        
                        // Tools Grid
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                                ForEach(enabledTools) { tool in
                                                                    ToolCard(tool: tool) {
                                    withAnimation(.easeInOut(duration: AppConstants.Animation.standard)) {
                                        selectedTool = tool
                                    }
                                }
                                .toolAccessibility(tool: tool)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        }
                    }
                }
            }
            
            // Floating Settings Button
            if !showingSettings && selectedTool == nil {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { 
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showingSettings = true 
                            }
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                )
                        }
                        .buttonStyle(.borderless)
                        .help("Settings")
                        .padding(.trailing, 16)
                        .padding(.top, 12)
                    }
                    Spacer()
                }
            }
        }
        .frame(width: settingsManager.windowSize.width, height: settingsManager.windowSize.height)
        .background(Color(NSColor.windowBackgroundColor))
        .colorScheme(settingsManager.theme.colorScheme ?? (NSApp.effectiveAppearance.name == .darkAqua ? .dark : .light))
    }
}

struct ToolCard: View {
    let tool: DevTool
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon
                Image(systemName: tool.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.blue)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(.blue.opacity(0.1))
                    )
                
                // Title and description
                VStack(spacing: 4) {
                    Text(tool.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                    
                    Text(tool.description)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity)
                                        .frame(height: AppConstants.UI.toolCardHeight)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .shadow(
                        color: .black.opacity(isHovered ? 0.12 : 0.04),
                        radius: isHovered ? 8 : 4,
                        x: 0,
                        y: isHovered ? 4 : 2
                    )
            )
            .scaleEffect(isHovered ? 1.03 : 1.0)
            .onHover { hovering in
                                                withAnimation(.easeInOut(duration: AppConstants.Animation.quick)) {
                                    isHovered = hovering
                                }
            }
        }
        .buttonStyle(.borderless)
    }
}

#Preview {
    ContentView()
        .environmentObject(SettingsManager.shared)
}
