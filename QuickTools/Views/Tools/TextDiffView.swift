//
//  TextDiffView.swift
//  QuickTools
//
//  Created by Shakthi M on 29/07/25.
//

import SwiftUI

struct TextDiffView: View {
    @State private var leftText = ""
    @State private var rightText = ""
    @State private var differences: [DiffLine] = []
    @State private var showLineNumbers = true
    @State private var ignoreWhitespace = false
    
    struct DiffLine: Identifiable {
        let id = UUID()
        let lineNumber: Int
        let leftContent: String?
        let rightContent: String?
        let type: DiffType
    }
    
    enum DiffType {
        case equal
        case added
        case removed
        case modified
        
        var color: Color {
            switch self {
            case .equal: return .clear
            case .added: return .green.opacity(0.2)
            case .removed: return .red.opacity(0.2)
            case .modified: return .orange.opacity(0.2)
            }
        }
        
        var prefix: String {
            switch self {
            case .equal: return " "
            case .added: return "+"
            case .removed: return "-"
            case .modified: return "~"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Controls
            HStack(spacing: 8) {
                Button("Compare") {
                    compareTexts()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                
                Button("Clear") {
                    leftText = ""
                    rightText = ""
                    differences = []
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Spacer()
                
                Toggle("Line Numbers", isOn: $showLineNumbers)
                    .font(.caption)
                    .toggleStyle(.checkbox)
                
                Toggle("Ignore Whitespace", isOn: $ignoreWhitespace)
                    .font(.caption)
                    .toggleStyle(.checkbox)
            }
            
            // Input Section
            HStack(spacing: 8) {
                // Left Text
                VStack(alignment: .leading, spacing: 6) {
                    Text("Original Text")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                    
                    ScrollView {
                        TextEditor(text: $leftText)
                            .font(.system(.caption, design: .monospaced))
                            .frame(minHeight: 80)
                    }
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Right Text
                VStack(alignment: .leading, spacing: 6) {
                    Text("Modified Text")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                    
                    ScrollView {
                        TextEditor(text: $rightText)
                            .font(.system(.caption, design: .monospaced))
                            .frame(minHeight: 80)
                    }
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            
            // Diff Results
            if !differences.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Differences")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(differences.filter { $0.type != .equal }.count) changes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    ScrollView {
                        LazyVStack(spacing: 1) {
                            ForEach(differences) { diff in
                                DiffLineView(
                                    diff: diff,
                                    showLineNumbers: showLineNumbers
                                )
                            }
                        }
                    }
                    .frame(maxHeight: 150)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            
            // Stats
            if !differences.isEmpty {
                HStack(spacing: 16) {
                    StatItem(
                        label: "Added",
                        count: differences.filter { $0.type == .added }.count,
                        color: .green
                    )
                    
                    StatItem(
                        label: "Removed",
                        count: differences.filter { $0.type == .removed }.count,
                        color: .red
                    )
                    
                    StatItem(
                        label: "Modified",
                        count: differences.filter { $0.type == .modified }.count,
                        color: .orange
                    )
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func compareTexts() {
        let leftLines = leftText.components(separatedBy: .newlines)
        let rightLines = rightText.components(separatedBy: .newlines)
        
        differences = []
        var lineNumber = 1
        let maxLines = max(leftLines.count, rightLines.count)
        
        for i in 0..<maxLines {
            let leftLine = i < leftLines.count ? leftLines[i] : nil
            let rightLine = i < rightLines.count ? rightLines[i] : nil
            
            let processedLeft = ignoreWhitespace ? leftLine?.trimmingCharacters(in: .whitespacesAndNewlines) : leftLine
            let processedRight = ignoreWhitespace ? rightLine?.trimmingCharacters(in: .whitespacesAndNewlines) : rightLine
            
            let diffType: DiffType
            if processedLeft == processedRight {
                diffType = .equal
            } else if leftLine == nil {
                diffType = .added
            } else if rightLine == nil {
                diffType = .removed
            } else {
                diffType = .modified
            }
            
            differences.append(DiffLine(
                lineNumber: lineNumber,
                leftContent: leftLine,
                rightContent: rightLine,
                type: diffType
            ))
            
            lineNumber += 1
        }
    }
}

struct DiffLineView: View {
    let diff: TextDiffView.DiffLine
    let showLineNumbers: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            if showLineNumbers {
                Text("\(diff.lineNumber)")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 30, alignment: .trailing)
                    .padding(.trailing, 8)
            }
            
            Text(diff.type.prefix)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(diff.type == .added ? .green : diff.type == .removed ? .red : .orange)
                .frame(width: 20)
            
            HStack(spacing: 8) {
                Text(diff.leftContent ?? "")
                    .font(.system(.caption, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                Text(diff.rightContent ?? "")
                    .font(.system(.caption, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(diff.type.color)
    }
}

struct StatItem: View {
    let label: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("\(count)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

#Preview {
    TextDiffView()
        .frame(width: 450, height: 500)
} 