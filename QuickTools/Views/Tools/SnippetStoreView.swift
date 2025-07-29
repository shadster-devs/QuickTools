//
//  SnippetStoreView.swift
//  QuickTools
//
//  Created by Shakthi M on 29/07/25.
//

import SwiftUI

struct SnippetStoreView: View {
    @StateObject private var snippetStore = SnippetStore()
    @State private var searchText = ""
    @State private var selectedSnippet: CodeSnippet?
    @State private var isAddingSnippet = false
    @State private var newTitle = ""
    @State private var newContent = ""

    
    var filteredSnippets: [CodeSnippet] {
        if searchText.isEmpty {
            return snippetStore.snippets.sorted { $0.updatedAt > $1.updatedAt }
        } else {
            return snippetStore.snippets.filter { snippet in
                snippet.title.localizedCaseInsensitiveContains(searchText) ||
                snippet.content.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.updatedAt > $1.updatedAt }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isAddingSnippet {
                // Full-width Add View
                AddSnippetView(
                    title: $newTitle,
                    content: $newContent,
                    onSave: saveNewSnippet,
                    onCancel: cancelAddingSnippet
                )
            } else {
                // Search Header
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search snippets...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    
                    Button("New") {
                        startAddingSnippet()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                .padding()
                .background(.ultraThinMaterial)
                
                Divider()
                
                // Split View
                HStack(spacing: 0) {
                    // Left: Snippets List
                    VStack(spacing: 0) {
                        if filteredSnippets.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "chevron.left.forwardslash.chevron.right")
                                    .font(.system(size: 30))
                                    .foregroundColor(.secondary)
                                
                                VStack(spacing: 4) {
                                    Text(snippetStore.snippets.isEmpty ? "No snippets yet" : "No results")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(snippetStore.snippets.isEmpty ? "Add some code snippets" : "Try a different search")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 1) {
                                    ForEach(filteredSnippets) { snippet in
                                        SnippetRow(
                                            snippet: snippet,
                                            isSelected: selectedSnippet?.id == snippet.id,
                                            onSelect: { selectedSnippet = snippet },
                                            onDelete: { 
                                                if selectedSnippet?.id == snippet.id {
                                                    selectedSnippet = nil
                                                }
                                                snippetStore.deleteSnippet(snippet) 
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .frame(width: 200)
                    
                    Divider()
                    
                    // Right: Snippet Content
                    if let snippet = selectedSnippet {
                        SnippetDetailView(snippet: snippet)
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text("Select a snippet to view")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(NSColor.textBackgroundColor).opacity(0.5))
                    }
                }
            }
        }
        .onAppear {
            if selectedSnippet == nil && !filteredSnippets.isEmpty && !isAddingSnippet {
                selectedSnippet = filteredSnippets.first
            }
        }
    }
    
    private func startAddingSnippet() {
        newTitle = ""
        newContent = ""
        isAddingSnippet = true
        selectedSnippet = nil
    }
    
    private func cancelAddingSnippet() {
        isAddingSnippet = false
        if !filteredSnippets.isEmpty {
            selectedSnippet = filteredSnippets.first
        }
    }
    
    private func saveNewSnippet() {
        let snippet = CodeSnippet(
            title: newTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            content: newContent
        )
        snippetStore.addSnippet(snippet)
        
        isAddingSnippet = false
        selectedSnippet = snippet
    }
}

struct SnippetRow: View {
    let snippet: CodeSnippet
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 10) {
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(snippet.title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    Text(snippet.content)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Delete button
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.secondary)
                        .font(.caption2)
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .buttonStyle(.borderless)
        .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
    }
}

struct SnippetDetailView: View {
    let snippet: CodeSnippet
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(snippet.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                CopyButton(text: snippet.content, id: snippet.id.uuidString)
            }
            .padding()
            .background(.ultraThinMaterial)
            
            Divider()
            
            // Content
            ScrollView {
                Text(snippet.content)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding()
            }
            .background(Color(NSColor.textBackgroundColor))
        }
    }
}

struct AddSnippetView: View {
    @Binding var title: String
    @Binding var content: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .buttonStyle(.borderless)
                
                Spacer()
                
                Text("New Snippet")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Add") {
                    onSave()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .disabled(!canSave)
            }
            .padding()
            .background(.ultraThinMaterial)
            
            Divider()
            
            // Form
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        TextField("Enter snippet title", text: $title)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Content")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextEditor(text: $content)
                            .font(.system(.body, design: .monospaced))
                            .frame(minHeight: 300)
                            .padding(8)
                            .background(Color(NSColor.textBackgroundColor))
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    SnippetStoreView()
        .frame(width: 450, height: 600)
} 