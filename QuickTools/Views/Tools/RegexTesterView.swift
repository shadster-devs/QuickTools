//
//  RegexTesterView.swift
//  QuickTools
//
//  Created by Shakthi M on 29/07/25.
//

import SwiftUI

struct RegexTesterView: View {
    @State private var pattern = ""
    @State private var testString = ""
    @State private var matches: [NSTextCheckingResult] = []
    @State private var errorMessage = ""
    @State private var isCaseSensitive = true
    @State private var isMultiline = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Pattern Input
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Regex Pattern")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Button("Clear") {
                        pattern = ""
                        testString = ""
                        matches = []
                        errorMessage = ""
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(.secondary)
                }
                
                TextField("Enter regex pattern (e.g., \\d+|[a-z]+@[a-z]+\\.[a-z]+)", text: $pattern)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.caption, design: .monospaced))
                
                // Options
                HStack(spacing: 16) {
                    Toggle("Case Sensitive", isOn: $isCaseSensitive)
                    Toggle("Multiline", isOn: $isMultiline)
                    Spacer()
                }
                .font(.caption)
                .toggleStyle(.checkbox)
            }
            
            // Test String Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Test String")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ScrollView {
                    TextEditor(text: $testString)
                        .font(.system(.caption, design: .monospaced))
                        .frame(minHeight: 60)
                }
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
            }
            
            // Test Button & Status
            HStack {
                Button("Test Regex") {
                    testRegex()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                
                Spacer()
                
                // Status
                if !errorMessage.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text("Error")
                            .foregroundColor(.red)
                    }
                    .font(.caption)
                } else if !matches.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("\(matches.count) match\(matches.count == 1 ? "" : "es")")
                            .foregroundColor(.green)
                    }
                    .font(.caption)
                } else if !pattern.isEmpty && !testString.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.orange)
                        Text("No matches")
                            .foregroundColor(.orange)
                    }
                    .font(.caption)
                }
            }
            
            // Matches Display
            if !matches.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Matches (\(matches.count))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        CopyButton(text: matches.map { match in
                            String(testString[Range(match.range, in: testString)!])
                        }.joined(separator: "\n"), id: "matches")
                    }
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(Array(matches.enumerated()), id: \.offset) { index, match in
                                let matchedString = String(testString[Range(match.range, in: testString)!])
                                HStack(spacing: 8) {
                                    Text("\(index + 1).")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.blue)
                                        .frame(width: 20, alignment: .trailing)
                                    
                                    Text(matchedString)
                                        .font(.system(.caption, design: .monospaced))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(4)
                                        .textSelection(.enabled)
                                    
                                    Text("(\(match.range.location), \(match.range.length))")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 100)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .padding(8)
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
        .onChange(of: pattern) { _ in
            if !pattern.isEmpty && !testString.isEmpty {
                testRegex()
            } else {
                matches = []
                errorMessage = ""
            }
        }
        .onChange(of: testString) { _ in
            if !pattern.isEmpty && !testString.isEmpty {
                testRegex()
            } else {
                matches = []
                errorMessage = ""
            }
        }
        .onChange(of: isCaseSensitive) { _ in
            if !pattern.isEmpty && !testString.isEmpty {
                testRegex()
            }
        }
        .onChange(of: isMultiline) { _ in
            if !pattern.isEmpty && !testString.isEmpty {
                testRegex()
            }
        }
    }
    
    private func testRegex() {
        guard !pattern.isEmpty else {
            errorMessage = "Please enter a regex pattern"
            matches = []
            return
        }
        
        guard !testString.isEmpty else {
            errorMessage = "Please enter a test string"
            matches = []
            return
        }
        
        do {
            var options: NSRegularExpression.Options = []
            if !isCaseSensitive {
                options.insert(.caseInsensitive)
            }
            if isMultiline {
                options.insert(.anchorsMatchLines)
            }
            
            let regex = try NSRegularExpression(pattern: pattern, options: options)
            let range = NSRange(location: 0, length: testString.utf16.count)
            matches = regex.matches(in: testString, options: [], range: range)
            errorMessage = ""
        } catch {
            errorMessage = "Invalid regex: \(error.localizedDescription)"
            matches = []
        }
    }
}

#Preview {
    RegexTesterView()
        .frame(width: 450, height: 500)
} 