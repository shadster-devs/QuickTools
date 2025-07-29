//
//  TimestampConverterView.swift
//  QuickTools
//
//  Created by Shakthi M on 29/07/25.
//

import SwiftUI

struct TimestampConverterView: View {
    @State private var timestampInput = ""
    @State private var dateInput = Date()
    @State private var convertedDate = ""
    @State private var convertedTimestamp = ""
    @State private var errorMessage = ""
    @State private var selectedTimeZone = TimeZone.current
    @State private var timestampUnit: TimestampUnit = .seconds
    
    enum TimestampUnit: String, CaseIterable {
        case seconds = "Seconds"
        case milliseconds = "Milliseconds"
        
        var divisor: Double {
            switch self {
            case .seconds: return 1
            case .milliseconds: return 1000
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Current time display
            VStack(spacing: 8) {
                Text("Current Time")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Timestamp")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            Text("\(Int(Date().timeIntervalSince1970))")
                                .font(.system(.caption, design: .monospaced))
                                .textSelection(.enabled)
                            CopyButton(text: "\(Int(Date().timeIntervalSince1970))", id: "current_timestamp")
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Date")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            Text(DateFormatter.readable.string(from: Date()))
                                .font(.system(.caption, design: .monospaced))
                                .textSelection(.enabled)
                            CopyButton(text: DateFormatter.readable.string(from: Date()), id: "current_date")
                        }
                    }
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
            
            Divider()
            
            // Timestamp to Date
            VStack(alignment: .leading, spacing: 8) {
                Text("Timestamp → Date")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 8) {
                    TextField("Enter timestamp", text: $timestampInput)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.caption, design: .monospaced))
                    
                    Picker("Unit", selection: $timestampUnit) {
                        ForEach(TimestampUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 100)
                    
                    Button("Convert") {
                        convertTimestampToDate()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                
                if !convertedDate.isEmpty {
                    HStack {
                        Text(convertedDate)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                            .background(Color(NSColor.textBackgroundColor))
                            .cornerRadius(6)
                        
                        CopyButton(text: convertedDate, id: "converted_date")
                    }
                }
            }
            
            Divider()
            
            // Date to Timestamp
            VStack(alignment: .leading, spacing: 8) {
                Text("Date → Timestamp")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 8) {
                    DatePicker("Date", selection: $dateInput, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .font(.caption)
                    
                    Button("Convert") {
                        convertDateToTimestamp()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                
                if !convertedTimestamp.isEmpty {
                    VStack(spacing: 6) {
                        HStack {
                            Text("Seconds:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(convertedTimestamp)
                                .font(.system(.caption, design: .monospaced))
                                .textSelection(.enabled)
                            Spacer()
                            CopyButton(text: convertedTimestamp, id: "timestamp_seconds")
                        }
                        .padding(6)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(6)
                        
                        HStack {
                            Text("Milliseconds:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(Int(dateInput.timeIntervalSince1970 * 1000))")
                                .font(.system(.caption, design: .monospaced))
                                .textSelection(.enabled)
                            Spacer()
                            CopyButton(text: "\(Int(dateInput.timeIntervalSince1970 * 1000))", id: "timestamp_millis")
                        }
                        .padding(6)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(6)
                    }
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
        .onChange(of: timestampInput) { _, _ in
            if timestampInput.isEmpty {
                convertedDate = ""
                errorMessage = ""
            }
        }
    }
    
    private func convertTimestampToDate() {
        guard !timestampInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a timestamp"
            convertedDate = ""
            return
        }
        
        guard let timestamp = Double(timestampInput) else {
            errorMessage = "Invalid timestamp format"
            convertedDate = ""
            return
        }
        
        let adjustedTimestamp = timestamp / timestampUnit.divisor
        let date = Date(timeIntervalSince1970: adjustedTimestamp)
        
        // Check if the date is reasonable (between 1970 and 2100)
        let minDate = Date(timeIntervalSince1970: 0)
        let maxDate = Date(timeIntervalSince1970: 4102444800) // Year 2100
        
        guard date >= minDate && date <= maxDate else {
            errorMessage = "Timestamp out of reasonable range"
            convertedDate = ""
            return
        }
        
        convertedDate = DateFormatter.readable.string(from: date)
        errorMessage = ""
    }
    
    private func convertDateToTimestamp() {
        convertedTimestamp = "\(Int(dateInput.timeIntervalSince1970))"
        errorMessage = ""
    }
}

extension DateFormatter {
    static let readable: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}

#Preview {
    TimestampConverterView()
        .frame(width: 450, height: 500)
} 