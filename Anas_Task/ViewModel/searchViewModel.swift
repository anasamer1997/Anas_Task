//
//  searchViewModel.swift
//  AnasTask
//
//  Created by Anas Amer on 27/01/1447 AH.
//

import Foundation
import Combine
@MainActor
final class SearchViewModel: ObservableObject {
    private let searchNetworkClient = NetworkClient(baseURL: URL(string: "https://mock.apidog.com/m1/735111-711675-default/")!)
    
    // Published properties for SwiftUI
    @Published private(set) var searchResults: SearchResponse?
    @Published private(set) var isSearching = false
    @Published private(set) var errorMessage: String?
    
    private var currentSearchTask: Task<Void, Never>?
    private var lastSearchQuery = ""
    
    func search(query: String) {
        currentSearchTask?.cancel() // Cancel previous task if exists
        
        guard !query.isEmpty else {
            clearSearch()
            return
        }
        
        currentSearchTask = Task {
            // Wait for 200ms before proceeding
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            // Check if we're still the current task and query hasn't changed
            guard !Task.isCancelled, lastSearchQuery == query else { return }
            
            await performSearch(query: query)
        }
        
        lastSearchQuery = query
    }
    
    private func performSearch(query: String) async {
        isSearching = true
        errorMessage = nil
        
        do {
            let results = try await searchNetworkClient.execute(SampleAPI.SearchMedia(query: query))
            searchResults = results
        } catch {
            errorMessage = (error as? NetworkError)?.errorDescription ?? "Search failed"
            searchResults = SearchResponse(sections: [])
        }
        
        isSearching = false
    }
    
    func clearSearch() {
        currentSearchTask?.cancel()
        searchResults = SearchResponse(sections: [])
        isSearching = false
        errorMessage = nil
        lastSearchQuery = ""
    }
}
