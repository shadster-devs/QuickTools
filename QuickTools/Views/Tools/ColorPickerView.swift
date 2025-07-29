//
//  ColorPickerView.swift
//  QuickTools
//
//  Created by Shakthi M on 29/07/25.
//

import SwiftUI

struct ColorPickerView: View {
    @State private var selectedColor = Color.blue
    @State private var colorInput = ""
    @State private var errorMessage = ""
    @State private var colorHistory: [SavedColor] = []
    
    struct SavedColor: Identifiable, Codable {
        let id: UUID
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double
        let timestamp: Date
        
        var color: Color {
            Color(red: red, green: green, blue: blue, opacity: alpha)
        }
        
        init(color: Color) {
            self.id = UUID()
            guard let nsColor = NSColor(color).usingColorSpace(.sRGB) else {
                self.red = 0
                self.green = 0
                self.blue = 0
                self.alpha = 1
                self.timestamp = Date()
                return
            }
            self.red = Double(nsColor.redComponent)
            self.green = Double(nsColor.greenComponent)
            self.blue = Double(nsColor.blueComponent)
            self.alpha = Double(nsColor.alphaComponent)
            self.timestamp = Date()
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Color Preview
                VStack(spacing: 12) {
                    Text("Color Preview")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedColor)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    Button("Save to History") {
                        saveColorToHistory()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Color Picker
                VStack(spacing: 12) {
                    Text("Pick Color")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        ColorPicker("Select Color", selection: $selectedColor, supportsOpacity: true)
                            .frame(height: 44)
                        
                        Spacer()
                        
                        // Alternative button approach
                        Button("Open Color Panel") {
                            NSColorPanel.shared.setTarget(nil)
                            NSColorPanel.shared.setAction(nil)
                            NSColorPanel.shared.color = NSColor(selectedColor)
                            NSColorPanel.shared.isContinuous = true
                            NSColorPanel.shared.showsAlpha = true
                            NSColorPanel.shared.orderFront(nil)
                            
                            // Monitor for color changes
                            NotificationCenter.default.addObserver(
                                forName: NSColorPanel.colorDidChangeNotification,
                                object: NSColorPanel.shared,
                                queue: .main
                            ) { _ in
                                selectedColor = Color(NSColorPanel.shared.color)
                            }
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Manual Input
                VStack(spacing: 12) {
                    Text("Enter Color")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        TextField("HEX, RGB, or CSS color name", text: $colorInput)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                            .onSubmit { parseColor() }
                        
                        Button("Apply") { parseColor() }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                    }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Color Values
                VStack(spacing: 12) {
                    Text("Color Values")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        ColorValueRow(title: "HEX", value: selectedColor.toHex())
                        ColorValueRow(title: "RGB", value: selectedColor.toRGB())
                        ColorValueRow(title: "CSS", value: selectedColor.toCSSRGB())
                        ColorValueRow(title: "Swift", value: selectedColor.toSwift())
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Color History
                if !colorHistory.isEmpty {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Recent Colors")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            Button("Clear") {
                                colorHistory.removeAll()
                                saveHistory()
                            }
                            .buttonStyle(.borderless)
                            .foregroundColor(.secondary)
                            .controlSize(.small)
                        }
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
                            ForEach(colorHistory.reversed().prefix(18), id: \.id) { savedColor in
                                Button(action: {
                                    selectedColor = savedColor.color
                                }) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(savedColor.color)
                                        .frame(height: 40)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .onAppear {
            loadHistory()
        }
        .onChange(of: selectedColor) { _ in
            errorMessage = ""
        }
    }
    
    private func saveColorToHistory() {
        let newColor = SavedColor(color: selectedColor)
        
        // Remove duplicates (similar colors)
        colorHistory.removeAll { savedColor in
            abs(savedColor.red - newColor.red) < 0.01 &&
            abs(savedColor.green - newColor.green) < 0.01 &&
            abs(savedColor.blue - newColor.blue) < 0.01
        }
        
        colorHistory.append(newColor)
        
        // Keep only last 30 colors
        if colorHistory.count > AppConstants.Limits.maxColorHistory {
            colorHistory = Array(colorHistory.suffix(AppConstants.Limits.maxColorHistory))
        }
        
        saveHistory()
    }
    
    private func saveHistory() {
        if let data = try? JSONEncoder().encode(colorHistory) {
            UserDefaults.standard.set(data, forKey: AppConstants.UserDefaultsKeys.colorPickerHistory)
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: AppConstants.UserDefaultsKeys.colorPickerHistory),
           let history = try? JSONDecoder().decode([SavedColor].self, from: data) {
            colorHistory = history
        }
    }
    
    private func parseColor() {
        let input = colorInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !input.isEmpty else {
            errorMessage = "Enter a color value"
            return
        }
        
        errorMessage = ""
        
        if let color = parseHex(input) ?? parseRGB(input) ?? parseCSS(input) {
            selectedColor = color
            saveColorToHistory()
        } else {
            errorMessage = "Invalid color format"
        }
    }
    
    private func parseHex(_ input: String) -> Color? {
        var hex = input.replacingOccurrences(of: "#", with: "")
        
        if hex.count == 3 {
            hex = String(hex.map { "\($0)\($0)" }.joined())
        }
        
        guard hex.count == 6, let rgb = UInt64(hex, radix: 16) else { return nil }
        
        return Color(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
    
    private func parseRGB(_ input: String) -> Color? {
        let clean = input.replacingOccurrences(of: "rgb(", with: "").replacingOccurrences(of: ")", with: "")
        let parts = clean.split(separator: ",").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        
        guard parts.count == 3 else { return nil }
        return Color(red: parts[0] / 255, green: parts[1] / 255, blue: parts[2] / 255)
    }
    
    private func parseCSS(_ input: String) -> Color? {
        let colors: [String: Color] = [
            "red": .red, "green": .green, "blue": .blue, "yellow": .yellow,
            "orange": .orange, "purple": .purple, "pink": .pink, "brown": .brown,
            "black": .black, "white": .white, "gray": .gray, "clear": .clear
        ]
        return colors[input]
    }
}

struct ColorValueRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 50, alignment: .leading)
            
            Text(value)
                .font(.system(.subheadline, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            CopyButton(text: value, id: title.lowercased())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.primary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}



#Preview {
    ColorPickerView()
        .frame(width: 450, height: 600)
} 