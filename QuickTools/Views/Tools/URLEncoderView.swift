//
//  URLEncoderView.swift
//  QuickTools
//
//  Created by Shakthi M on 29/07/25.
//

import SwiftUI

struct URLEncoderView: View {
    @State private var inputText = ""
    @State private var encodedText = ""
    @State private var decodedText = ""
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 12) {
            // Input Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Input Text")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Button("Clear") {
                        inputText = ""
                        encodedText = ""
                        decodedText = ""
                        errorMessage = ""
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(.secondary)
                }
                
                ScrollView {
                    TextEditor(text: $inputText)
                        .font(.system(.caption, design: .monospaced))
                        .frame(minHeight: 60)
                }
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
            }
            
            // Action Buttons
            HStack(spacing: 8) {
                Button("Encode") {
                    encodeURL()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                
                Button("Decode") {
                    decodeURL()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button("Encode Components") {
                    encodeURLComponents()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Spacer()
            }
            
            // Encoded Output
            if !encodedText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Encoded Output")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        CopyButton(text: encodedText, id: "encoded")
                    }
                    
                    ScrollView {
                        Text(encodedText)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                    }
                    .frame(maxHeight: 80)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.green.opacity(0.5), lineWidth: 1)
                    )
                }
            }
            
            // Decoded Output
            if !decodedText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Decoded Output")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        CopyButton(text: decodedText, id: "decoded")
                    }
                    
                    ScrollView {
                        Text(decodedText)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                    }
                    .frame(maxHeight: 80)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue.opacity(0.5), lineWidth: 1)
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
    }
    
    private func encodeURL() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter some text to encode"
            return
        }
        
        if let encoded = inputText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            encodedText = encoded
            decodedText = ""
            errorMessage = ""
        } else {
            errorMessage = "Failed to encode text"
            encodedText = ""
        }
    }
    
    private func encodeURLComponents() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter some text to encode"
            return
        }
        
        if let encoded = inputText.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
            encodedText = encoded
            decodedText = ""
            errorMessage = ""
        } else {
            errorMessage = "Failed to encode text"
            encodedText = ""
        }
    }
    
    private func decodeURL() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter some text to decode"
            return
        }
        
        if let decoded = inputText.removingPercentEncoding {
            decodedText = decoded
            encodedText = ""
            errorMessage = ""
        } else {
            errorMessage = "Failed to decode text - invalid URL encoding"
            decodedText = ""
        }
    }
}

#Preview {
    URLEncoderView()
        .frame(width: 450, height: 500)
} 