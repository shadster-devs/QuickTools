//
//  HashGeneratorView.swift
//  QuickTools
//
//  Created by Shakthi M on 29/07/25.
//

import SwiftUI
import CryptoKit

struct HashGeneratorView: View {
    @State private var inputText = ""
    @State private var md5Hash = ""
    @State private var sha1Hash = ""
    @State private var sha256Hash = ""
    @State private var sha512Hash = ""
    @State private var isFileMode = false
    @State private var selectedFileURL: URL?
    
    var body: some View {
        VStack(spacing: 12) {
            // Mode Picker
            Picker("Input Mode", selection: $isFileMode) {
                Text("Text").tag(false)
                Text("File").tag(true)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Input Section
            if isFileMode {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select File")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        Text(selectedFileURL?.lastPathComponent ?? "No file selected")
                            .font(.caption)
                            .foregroundColor(selectedFileURL == nil ? .secondary : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button("Choose File") {
                            selectFile()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .padding(8)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Input Text")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Button("Clear") {
                            inputText = ""
                            clearHashes()
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
            }
            
            // Generate Button
            Button("Generate Hashes") {
                if isFileMode {
                    generateFileHashes()
                } else {
                    generateTextHashes()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .disabled(isFileMode ? selectedFileURL == nil : inputText.isEmpty)
            
            // Hash Results
            if !md5Hash.isEmpty || !sha1Hash.isEmpty || !sha256Hash.isEmpty || !sha512Hash.isEmpty {
                VStack(spacing: 8) {
                    if !md5Hash.isEmpty {
                        CompactHashRow(title: "MD5", hash: md5Hash, color: .orange)
                    }
                    if !sha1Hash.isEmpty {
                        CompactHashRow(title: "SHA-1", hash: sha1Hash, color: .blue)
                    }
                    if !sha256Hash.isEmpty {
                        CompactHashRow(title: "SHA-256", hash: sha256Hash, color: .green)
                    }
                    if !sha512Hash.isEmpty {
                        CompactHashRow(title: "SHA-512", hash: sha512Hash, color: .purple)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .onChange(of: isFileMode) { _ in
            clearHashes()
            selectedFileURL = nil
        }
        .onChange(of: inputText) { _ in
            if inputText.isEmpty {
                clearHashes()
            }
        }
    }
    
    private func selectFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK {
            selectedFileURL = panel.url
        }
    }
    
    private func generateTextHashes() {
        guard !inputText.isEmpty else { return }
        
        let data = inputText.data(using: .utf8) ?? Data()
        
        // MD5
        md5Hash = Insecure.MD5.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
        
        // SHA-1
        sha1Hash = Insecure.SHA1.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
        
        // SHA-256
        sha256Hash = SHA256.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
        
        // SHA-512
        sha512Hash = SHA512.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
    }
    
    private func generateFileHashes() {
        guard let fileURL = selectedFileURL else { return }
        
        do {
            let data = try Data(contentsOf: fileURL)
            
            // MD5
            md5Hash = Insecure.MD5.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
            
            // SHA-1
            sha1Hash = Insecure.SHA1.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
            
            // SHA-256
            sha256Hash = SHA256.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
            
            // SHA-512
            sha512Hash = SHA512.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
            
        } catch {
            print("Error reading file: \(error)")
        }
    }
    
    private func clearHashes() {
        md5Hash = ""
        sha1Hash = ""
        sha256Hash = ""
        sha512Hash = ""
    }
}

struct CompactHashRow: View {
    let title: String
    let hash: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                Spacer()
                CopyButton(text: hash, id: title.lowercased())
            }
            
            Text(hash)
                .font(.system(.caption2, design: .monospaced))
                .textSelection(.enabled)
                .padding(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

#Preview {
    HashGeneratorView()
        .frame(width: 450, height: 500)
} 