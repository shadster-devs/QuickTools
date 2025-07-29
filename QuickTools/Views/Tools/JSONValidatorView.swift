//
//  JSONValidatorView.swift
//  QuickTools
//
//  Created by Shakthi M on 29/07/25.
//

import SwiftUI

struct JSONValidatorView: View {
    @State private var inputText = ""
    @State private var outputText = ""
    @State private var isValid = false
    @State private var errorMessage = ""
    @State private var copiedStates: [String: Bool] = [:]
    
    var body: some View {
        VStack(spacing: 12) {
            // Input Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("JSON Input")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Button("Clear") {
                        inputText = ""
                        outputText = ""
                        errorMessage = ""
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(.secondary)
                }
                
                ScrollView {
                    TextEditor(text: $inputText)
                        .font(.system(.caption, design: .monospaced))
                        .frame(minHeight: 80)
                }
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
            }
            
            // Action Buttons
            HStack(spacing: 8) {
                Button("Validate & Format") {
                    validateAndFormatJSON()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                
                Button("Minify") {
                    minifyJSON()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Spacer()
                
                // Status indicator
                if !errorMessage.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text("Invalid")
                            .foregroundColor(.red)
                    }
                    .font(.caption)
                } else if isValid && !outputText.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Valid")
                            .foregroundColor(.green)
                    }
                    .font(.caption)
                }
            }
            
            // Output Section
            if !outputText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Formatted JSON")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        CopyButton(text: outputText, id: "output")
                    }
                    
                    ScrollView {
                        Text(outputText)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                    }
                    .frame(maxHeight: 120)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isValid ? Color.green.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            
            // Error Message
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
            }
            
            Spacer()
        }
        .padding()
        .onChange(of: inputText) { _, _ in
            if inputText.isEmpty {
                outputText = ""
                errorMessage = ""
                isValid = false
            }
        }
    }
    
    private func validateAndFormatJSON() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter some JSON"
            isValid = false
            outputText = ""
            return
        }
        
        do {
            let data = inputText.data(using: .utf8) ?? Data()
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let formattedData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
            outputText = String(data: formattedData, encoding: .utf8) ?? ""
            isValid = true
            errorMessage = ""
        } catch {
            errorMessage = "Invalid JSON: \(error.localizedDescription)"
            isValid = false
            outputText = ""
        }
    }
    
    private func minifyJSON() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter some JSON"
            isValid = false
            outputText = ""
            return
        }
        
        do {
            let data = inputText.data(using: .utf8) ?? Data()
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let minifiedData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
            outputText = String(data: minifiedData, encoding: .utf8) ?? ""
            isValid = true
            errorMessage = ""
        } catch {
            errorMessage = "Invalid JSON: \(error.localizedDescription)"
            isValid = false
            outputText = ""
        }
    }
}



#Preview {
    JSONValidatorView()
        .frame(width: 450, height: 500)
} 