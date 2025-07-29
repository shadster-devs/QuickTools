//
//  SnippetModel.swift
//  QuickTools
//
//  Created by Shakthi M on 29/07/25.
//

import SwiftUI

struct CodeSnippet: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    let createdAt: Date
    var updatedAt: Date
    
    init(title: String, content: String) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}



class SnippetStore: ObservableObject {
    @Published var snippets: [CodeSnippet] = []
    
    private let userDefaults = UserDefaults.standard
    private let snippetsKey = "SavedCodeSnippets"
    
    init() {
        loadSnippets()
        addSampleSnippetsIfNeeded()
    }
    
    func addSnippet(_ snippet: CodeSnippet) {
        snippets.append(snippet)
        saveSnippets()
    }
    
    func updateSnippet(_ snippet: CodeSnippet) {
        if let index = snippets.firstIndex(where: { $0.id == snippet.id }) {
            var updatedSnippet = snippet
            updatedSnippet.updatedAt = Date()
            snippets[index] = updatedSnippet
            saveSnippets()
        }
    }
    
    func deleteSnippet(_ snippet: CodeSnippet) {
        snippets.removeAll { $0.id == snippet.id }
        saveSnippets()
    }
    
    private func saveSnippets() {
        if let data = try? JSONEncoder().encode(snippets) {
            userDefaults.set(data, forKey: snippetsKey)
        }
    }
    
    private func loadSnippets() {
        if let data = userDefaults.data(forKey: snippetsKey),
           let savedSnippets = try? JSONDecoder().decode([CodeSnippet].self, from: data) {
            snippets = savedSnippets
        }
    }
    
    private func addSampleSnippetsIfNeeded() {
        // Only add samples if no snippets exist
        guard snippets.isEmpty else { return }
        
        let sampleSnippets = [
            CodeSnippet(
                title: "SwiftUI View Template",
                content: """
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
                .padding()
        }
    }
}
"""
            ),
            
            CodeSnippet(
                title: "Array Filter Map",
                content: """
let numbers = [1, 2, 3, 4, 5, 6]
let evenSquares = numbers
    .filter { $0 % 2 == 0 }
    .map { $0 * $0 }
print(evenSquares) // [4, 16, 36]
"""
            ),
            
            CodeSnippet(
                title: "JSON Parse Function",
                content: """
function parseJSON(jsonString) {
    try {
        return JSON.parse(jsonString);
    } catch (error) {
        console.error('Invalid JSON:', error);
        return null;
    }
}
"""
            )
        ]
        
        for snippet in sampleSnippets {
            addSnippet(snippet)
        }
    }
} 