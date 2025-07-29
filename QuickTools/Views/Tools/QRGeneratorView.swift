//
//  QRGeneratorView.swift
//  QuickTools
//
//  Created by Shakthi M on 29/07/25.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct QRGeneratorView: View {
    @State private var inputText = ""
    @State private var qrImage: NSImage?
    @State private var qrSize: CGFloat = 200
    @State private var correctionLevel: CorrectionLevel = .medium
    @State private var errorMessage = ""
    @State private var generationHistory: [QRHistory] = []
    
    enum CorrectionLevel: String, CaseIterable {
        case low = "L"
        case medium = "M"
        case quartile = "Q"
        case high = "H"
        
        var displayName: String {
            switch self {
            case .low: return "Low (~7%)"
            case .medium: return "Medium (~15%)"
            case .quartile: return "Quartile (~25%)"
            case .high: return "High (~30%)"
            }
        }
    }
    
    struct QRHistory: Identifiable {
        let id = UUID()
        let text: String
        let timestamp: Date
        let image: NSImage
        
        var timeString: String {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: timestamp)
        }
        
        var displayText: String {
            return text.count > 30 ? String(text.prefix(30)) + "..." : text
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Input Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Text/URL Input")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Button("Clear") {
                            inputText = ""
                            qrImage = nil
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
                
                // Settings
                VStack(alignment: .leading, spacing: 8) {
                    Text("Settings")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Size")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack {
                                Text("\(Int(qrSize))px")
                                    .font(.caption)
                                    .monospacedDigit()
                                    .frame(width: 50, alignment: .trailing)
                                Slider(value: $qrSize, in: 100...400, step: 50)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Error Correction")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Picker("Correction", selection: $correctionLevel) {
                                ForEach(CorrectionLevel.allCases, id: \.self) { level in
                                    Text(level.displayName).tag(level)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 130)
                        }
                    }
                }
                .padding(12)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(10)
                
                // Generate Button
                Button("Generate QR Code") {
                    generateQRCode()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                // QR Code Display
                if let qrImage = qrImage {
                    VStack(spacing: 12) {
                        Image(nsImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: qrSize, height: qrSize)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        HStack(spacing: 8) {
                            Button("Save Image") {
                                saveQRImage()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            
                            Button("Copy Image") {
                                copyQRImage()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            
                            Button("Add to History") {
                                addToHistory()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                }
                
                // History
                if !generationHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Recent QR Codes")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Button("Clear") {
                                generationHistory.removeAll()
                            }
                            .buttonStyle(.borderless)
                            .foregroundColor(.secondary)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(generationHistory.reversed()) { item in
                                    QRHistoryItem(history: item) {
                                        inputText = item.text
                                        qrImage = item.image
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        .frame(height: 80)
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
                
                Spacer(minLength: 12)
            }
            .padding()
        }
    }
    
    private func generateQRCode() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter some text to generate QR code"
            return
        }
        
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(inputText.utf8)
        filter.correctionLevel = correctionLevel.rawValue
        
        if let outputImage = filter.outputImage {
            let scaleX = qrSize / outputImage.extent.size.width
            let scaleY = qrSize / outputImage.extent.size.height
            let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
            
            if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
                qrImage = NSImage(cgImage: cgImage, size: NSSize(width: qrSize, height: qrSize))
                errorMessage = ""
            } else {
                errorMessage = "Failed to generate QR code image"
                qrImage = nil
            }
        } else {
            errorMessage = "Failed to generate QR code"
            qrImage = nil
        }
    }
    
    private func saveQRImage() {
        guard let qrImage = qrImage else { return }
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = "qrcode.png"
        panel.title = "Save QR Code"
        
        if panel.runModal() == .OK {
            if let saveURL = panel.url,
               let tiffData = qrImage.tiffRepresentation,
               let bitmap = NSBitmapImageRep(data: tiffData),
               let pngData = bitmap.representation(using: .png, properties: [:]) {
                
                do {
                    try pngData.write(to: saveURL)
                } catch {
                    errorMessage = "Failed to save image: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func copyQRImage() {
        guard let qrImage = qrImage else { return }
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([qrImage])
    }
    
    private func addToHistory() {
        guard let qrImage = qrImage else { return }
        
        let historyItem = QRHistory(
            text: inputText,
            timestamp: Date(),
            image: qrImage
        )
        
        generationHistory.append(historyItem)
        
        // Keep only last 10 items
        if generationHistory.count > 10 {
            generationHistory = Array(generationHistory.suffix(10))
        }
    }
}

struct QRHistoryItem: View {
    let history: QRGeneratorView.QRHistory
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            Button(action: action) {
                Image(nsImage: history.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .background(Color.white)
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            .buttonStyle(.borderless)
            
            VStack(spacing: 2) {
                Text(history.displayText)
                    .font(.caption2)
                    .lineLimit(1)
                    .frame(width: 50)
                
                Text(history.timeString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    QRGeneratorView()
        .frame(width: 450, height: 500)
} 