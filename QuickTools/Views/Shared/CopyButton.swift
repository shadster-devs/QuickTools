//
//  CopyButton.swift
//  QuickTools
//
//  Created by Shakthi M on 29/07/25.
//

import SwiftUI

struct CopyButton: View {
    let text: String
    let id: String
    @State private var showCopied = false
    
    var body: some View {
        Button(action: {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(text, forType: .string)
            
            withAnimation(.easeInOut(duration: 0.2)) {
                showCopied = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showCopied = false
                }
            }
        }) {
            Text(showCopied ? "Copied!" : "Copy")
                .font(.caption)
                .foregroundColor(showCopied ? .green : .blue)
        }
        .buttonStyle(.borderless)
        .onHover { hovering in
            if hovering {
                NSCursor.pointingHand.set()
            } else {
                NSCursor.arrow.set()
            }
        }
        .accessibilityLabel("Copy \(text)")
        .accessibilityHint("Copies the text to clipboard")
        .keyboardShortcut("c", modifiers: [.command, .shift])
    }
} 