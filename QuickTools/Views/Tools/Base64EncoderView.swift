//
//  Base64EncoderView.swift
//  QuickTools
//
//  Created by Shakthi M on 29/07/25.
//

import SwiftUI

struct Base64EncoderView: View {
    @State private var inputText = ""
    @State private var outputText = ""
    @State private var errorMessage = ""
    @State private var isEncoding = true
    
    var body: some View {
        VStack(spacing: 12) {
            // Mode Picker
            Picker("Mode", selection: $isEncoding) {
                Text("Encode").tag(true)
                Text("Decode").tag(false)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Input Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(isEncoding ? "Plain Text Input" : "Base64 Input")
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
                Button(isEncoding ? "Encode to Base64" : "Decode from Base64") {
                    if isEncoding {
                        encodeToBase64()
                    } else {
                        decodeFromBase64()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                
                if isEncoding {
                    Button("Encode (URL Safe)") {
                        encodeToBase64URLSafe()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                
                Spacer()
            }
            
            // Output Section
            if !outputText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(isEncoding ? "Base64 Output" : "Decoded Output")
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
                    .frame(maxHeight: 100)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.green.opacity(0.5), lineWidth: 1)
                    )
                }
            }
            
            // Info section
            VStack(alignment: .leading, spacing: 4) {
                Text("💡 Tips:")
                    .font(.caption)
                    .fontWeight(.semibold)
                Text("• Standard Base64 uses +, /, and = characters")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("• URL-Safe Base64 uses -, _ and no padding")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
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
        .onChange(of: isEncoding) { _ in
            outputText = ""
            errorMessage = ""
        }
        .onChange(of: inputText) { _ in
            if inputText.isEmpty {
                outputText = ""
                errorMessage = ""
            }
        }
    }
    
    private func encodeToBase64() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter some text to encode"
            outputText = ""
            return
        }
        
        let data = inputText.data(using: .utf8) ?? Data()
        outputText = data.base64EncodedString()
        errorMessage = ""
    }
    
    private func encodeToBase64URLSafe() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter some text to encode"
            outputText = ""
            return
        }
        
        let data = inputText.data(using: .utf8) ?? Data()
        let base64 = data.base64EncodedString()
        // Convert to URL-safe format
        let urlSafe = base64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        
        outputText = urlSafe
        errorMessage = ""
    }
    
    private func decodeFromBase64() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter Base64 text to decode"
            outputText = ""
            return
        }
        
        var base64String = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Handle URL-safe Base64
        base64String = base64String
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Add padding if needed
        let remainder = base64String.count % 4
        if remainder > 0 {
            base64String += String(repeating: "=", count: 4 - remainder)
        }
        
        guard let data = Data(base64Encoded: base64String) else {
            errorMessage = "Invalid Base64 format"
            outputText = ""
            return
        }
        
        if let decodedString = String(data: data, encoding: .utf8) {
            outputText = decodedString
            errorMessage = ""
        } else {
            errorMessage = "Decoded data is not valid UTF-8 text"
            outputText = ""
        }
    }
}

#Preview {
    Base64EncoderView()
        .frame(width: 450, height: 500)
} 