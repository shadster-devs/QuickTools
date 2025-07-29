//
//  ImageConverterView.swift
//  QuickTools
//
//  Created by Shakthi M on 29/07/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImageConverterView: View {
    @State private var selectedImageURL: URL?
    @State private var selectedImage: NSImage?
    @State private var outputFormat: ImageFormat = .png
    @State private var jpegQuality: Double = 0.8
    @State private var errorMessage = ""
    @State private var isConverting = false
    @State private var conversionHistory: [ConversionHistory] = []
    
    enum ImageFormat: String, CaseIterable {
        case jpeg = "JPEG"
        case png = "PNG"
        case heic = "HEIC"
        case tiff = "TIFF"
        case bmp = "BMP"
        case gif = "GIF"
        
        var utType: UTType {
            switch self {
            case .jpeg: return .jpeg
            case .png: return .png
            case .heic: return .heic
            case .tiff: return .tiff
            case .bmp: return .bmp
            case .gif: return .gif
            }
        }
        
        var fileExtension: String {
            switch self {
            case .jpeg: return "jpg"
            case .png: return "png"
            case .heic: return "heic"
            case .tiff: return "tiff"
            case .bmp: return "bmp"
            case .gif: return "gif"
            }
        }
        
        var supportsQuality: Bool {
            return self == .jpeg
        }
    }
    
    struct ConversionHistory: Identifiable {
        let id = UUID()
        let originalName: String
        let outputFormat: ImageFormat
        let timestamp: Date
        let originalSize: String
        let convertedSize: String
        
        var timeString: String {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: timestamp)
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // File Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Select Image")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedImageURL?.lastPathComponent ?? "No image selected")
                            .font(.caption)
                            .foregroundColor(selectedImageURL == nil ? .secondary : .primary)
                            .lineLimit(1)
                        
                        if let url = selectedImageURL {
                            Text(formatFileSize(getFileSize(url: url)))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button("Choose Image") {
                        selectImage()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
            
            // Image Preview
            if let image = selectedImage {
                VStack(spacing: 6) {
                    Text("Preview")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 120, maxHeight: 80)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            
            // Format Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Output Format")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                VStack(spacing: 8) {
                    Picker("Format", selection: $outputFormat) {
                        ForEach(ImageFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                    
                    // JPEG Quality Slider
                    if outputFormat.supportsQuality {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Quality")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(Int(jpegQuality * 100))%")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .monospacedDigit()
                            }
                            
                            Slider(value: $jpegQuality, in: 0.1...1.0)
                                .accentColor(.blue)
                        }
                    }
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
            
            // Convert Button
            Button(action: {
                convertImage()
            }) {
                HStack(spacing: 6) {
                    if isConverting {
                        ProgressView()
                            .scaleEffect(0.8)
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                    Text(isConverting ? "Converting..." : "Convert & Save")
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .disabled(selectedImageURL == nil || isConverting)
            
            // Conversion History
            if !conversionHistory.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Recent Conversions")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Button("Clear") {
                            conversionHistory.removeAll()
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(.secondary)
                    }
                    
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(conversionHistory.reversed()) { item in
                                ConversionHistoryRow(conversion: item)
                            }
                        }
                    }
                    .frame(maxHeight: 80)
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
            
            // Tips
            VStack(alignment: .leading, spacing: 4) {
                Text("💡 Tips:")
                    .font(.caption)
                    .fontWeight(.semibold)
                Text("• PNG: Best for screenshots, graphics with transparency")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("• JPEG: Best for photos, smaller file sizes")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    private func selectImage() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.image]
        panel.title = "Select Image to Convert"
        
        if panel.runModal() == .OK {
            selectedImageURL = panel.url
            if let url = panel.url {
                selectedImage = NSImage(contentsOf: url)
                errorMessage = ""
            }
        }
    }
    
    private func convertImage() {
        guard let imageURL = selectedImageURL,
              let image = selectedImage else {
            errorMessage = "Please select an image first"
            return
        }
        
        isConverting = true
        errorMessage = ""
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let convertedData = try convertImageData(image: image, to: outputFormat, quality: jpegQuality)
                
                DispatchQueue.main.async {
                    saveConvertedImage(data: convertedData, originalURL: imageURL)
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Conversion failed: \(error.localizedDescription)"
                    self.isConverting = false
                }
            }
        }
    }
    
    private func convertImageData(image: NSImage, to format: ImageFormat, quality: Double) throws -> Data {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            throw NSError(domain: "ImageConverter", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not create bitmap representation"])
        }
        
        var properties: [NSBitmapImageRep.PropertyKey: Any] = [:]
        
        switch format {
        case .jpeg:
            properties[.compressionFactor] = quality
            return bitmap.representation(using: .jpeg, properties: properties) ?? Data()
        case .png:
            return bitmap.representation(using: .png, properties: properties) ?? Data()
        case .tiff:
            return bitmap.representation(using: .tiff, properties: properties) ?? Data()
        case .bmp:
            return bitmap.representation(using: .bmp, properties: properties) ?? Data()
        case .gif:
            return bitmap.representation(using: .gif, properties: properties) ?? Data()
        case .heic:
            // For HEIC, we need to use different approach, but for now fallback to JPEG
            properties[.compressionFactor] = quality
            return bitmap.representation(using: .jpeg, properties: properties) ?? Data()
        }
    }
    
    private func saveConvertedImage(data: Data, originalURL: URL) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [outputFormat.utType]
        panel.nameFieldStringValue = originalURL.deletingPathExtension().lastPathComponent + ".\(outputFormat.fileExtension)"
        panel.title = "Save Converted Image"
        
        if panel.runModal() == .OK {
            if let saveURL = panel.url {
                do {
                    try data.write(to: saveURL)
                    
                    // Add to history
                    let originalSize = getFileSize(url: originalURL)
                    let convertedSize = data.count
                    
                    let historyItem = ConversionHistory(
                        originalName: originalURL.lastPathComponent,
                        outputFormat: outputFormat,
                        timestamp: Date(),
                        originalSize: formatFileSize(originalSize),
                        convertedSize: formatFileSize(convertedSize)
                    )
                    
                    conversionHistory.append(historyItem)
                    
                    // Keep only last 10 conversions
                    if conversionHistory.count > 10 {
                        conversionHistory = Array(conversionHistory.suffix(10))
                    }
                    
                    errorMessage = ""
                } catch {
                    errorMessage = "Failed to save converted image: \(error.localizedDescription)"
                }
            }
        }
        
        isConverting = false
    }
    
    private func getFileSize(url: URL) -> Int {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int ?? 0
        } catch {
            return 0
        }
    }
    
    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

struct ConversionHistoryRow: View {
    let conversion: ImageConverterView.ConversionHistory
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(conversion.originalName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text("→ \(conversion.outputFormat.rawValue)")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("\(conversion.originalSize) → \(conversion.convertedSize)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(conversion.timeString)
                .font(.caption2)
                .foregroundColor(.secondary)
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
    ImageConverterView()
        .frame(width: 450, height: 500)
} 
