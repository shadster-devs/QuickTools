//
//  UUIDGeneratorView.swift
//  QuickTools
//
//  Created by Shakthi M on 29/07/25.
//

import SwiftUI

struct UUIDGeneratorView: View {
    @State private var generatedUUIDs: [GeneratedUUID] = []
    @State private var selectedFormat: UUIDFormat = .standard
    @State private var batchSize = 1
    
    enum UUIDFormat: String, CaseIterable {
        case standard = "Standard"
        case uppercase = "Uppercase"
        case noDashes = "No Dashes"
        case uppercaseNoDashes = "Uppercase No Dashes"
        case braces = "With Braces"
        
        func format(_ uuid: UUID) -> String {
            let uuidString = uuid.uuidString
            
            switch self {
            case .standard:
                return uuidString.lowercased()
            case .uppercase:
                return uuidString
            case .noDashes:
                return uuidString.lowercased().replacingOccurrences(of: "-", with: "")
            case .uppercaseNoDashes:
                return uuidString.replacingOccurrences(of: "-", with: "")
            case .braces:
                return "{\(uuidString.lowercased())}"
            }
        }
    }
    
    struct GeneratedUUID: Identifiable {
        let id = UUID()
        let uuid: UUID
        let timestamp: Date
        
        var timeString: String {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: timestamp)
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Configuration
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Format")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Picker("Format", selection: $selectedFormat) {
                            ForEach(UUIDFormat.allCases, id: \.self) { format in
                                Text(format.rawValue).tag(format)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                    }
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Batch Size")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Stepper(value: $batchSize, in: 1...AppConstants.Limits.maxBatchSize) {
                            Text("\(batchSize)")
                                .frame(width: 30, alignment: .center)
                                .font(.caption)
                        }
                        .controlSize(.small)
                    }
                }
                
                HStack(spacing: 8) {
                    Button("Generate UUID\(batchSize > 1 ? "s" : "")") {
                        generateUUIDs()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    
                    Button("Clear History") {
                        generatedUUIDs.removeAll()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(generatedUUIDs.isEmpty)
                    
                    Spacer()
                    
                    if !generatedUUIDs.isEmpty {
                        CopyButton(text: generatedUUIDs.map { selectedFormat.format($0.uuid) }.joined(separator: "\n"), id: "all_uuids")
                    }
                }
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)
            
            // Generated UUIDs
            if !generatedUUIDs.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Generated UUIDs (\(generatedUUIDs.count))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(generatedUUIDs.reversed()) { item in
                                CompactUUIDRow(
                                    uuid: item.uuid,
                                    format: selectedFormat,
                                    timestamp: item.timeString
                                )
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.below.ecg")
                        .font(.system(size: 30))
                        .foregroundColor(.secondary)
                    VStack(spacing: 4) {
                        Text("No UUIDs generated yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Click 'Generate UUID' to create unique identifiers")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Info section
            VStack(alignment: .leading, spacing: 4) {
                Text("💡 About UUIDs:")
                    .font(.caption)
                    .fontWeight(.semibold)
                Text("• Version 4 (random) UUIDs with 122 bits of entropy")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("• Virtually guaranteed to be unique across space and time")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    private func generateUUIDs() {
        for _ in 0..<batchSize {
            let newUUID = GeneratedUUID(uuid: UUID(), timestamp: Date())
            generatedUUIDs.append(newUUID)
        }
        
        // Keep only the last 50 UUIDs to prevent memory issues
        if generatedUUIDs.count > AppConstants.Limits.maxUUIDHistory {
            generatedUUIDs = Array(generatedUUIDs.suffix(AppConstants.Limits.maxUUIDHistory))
        }
    }
}

struct CompactUUIDRow: View {
    let uuid: UUID
    let format: UUIDGeneratorView.UUIDFormat
    let timestamp: String
    
    var formattedUUID: String {
        format.format(uuid)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(formattedUUID)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
                Text(timestamp)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            CopyButton(text: formattedUUID, id: uuid.uuidString)
        }
        .padding(8)
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    UUIDGeneratorView()
        .frame(width: 450, height: 500)
} 