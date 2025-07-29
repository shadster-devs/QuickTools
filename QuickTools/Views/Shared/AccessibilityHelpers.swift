//
//  AccessibilityHelpers.swift
//  QuickTools
//
//  Created by Shakthi M on 29/07/25.
//

import SwiftUI

extension View {
    /// Adds standard accessibility support for tool buttons
    func toolAccessibility(tool: DevTool) -> some View {
        self
            .accessibilityLabel(tool.name)
            .accessibilityHint(tool.description)
            .accessibilityAddTraits(.isButton)
    }
    
    /// Adds accessibility support for copy actions
    func copyAccessibility(content: String) -> some View {
        self
            .accessibilityLabel("Copy \(content)")
            .accessibilityHint("Copies the content to clipboard")
            .accessibilityAddTraits(.isButton)
    }
    
    /// Adds accessibility support for text input fields
    func inputAccessibility(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "Enter \(label.lowercased())")
    }
} 