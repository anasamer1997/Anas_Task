//
//  HomeViewModel.swift
//  AnasTask
//
//  Created by Anas Amer on 27/01/1447 AH.
//

import Foundation
import Combine
// Example ViewModel using the network layer
@MainActor
final class HomeViewModel: ObservableObject {
    private let networkClient = NetworkClient(baseURL: URL(string: "https://api-v2-b2sit6oh3a-uc.a.run.app/")!)
    
    @Published var sections: [Section] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    
    private var currentPage = 1
    private var totalPages = -1
    
    func loadInitialData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await networkClient.execute(SampleAPI.GetMedia(page: currentPage))
            sections.append(contentsOf: response.sections)
            totalPages = response.pagination.totalPages
            currentPage += 1
        } catch {
            errorMessage = (error as? NetworkError)?.errorDescription ?? "Failed to load data"
        }
        
        isLoading = false
    }
    
    func refresh() async {
        currentPage = 1
        totalPages = -1
        sections.removeAll()
        
        await loadInitialData()
    }
    
    func loadMoreIfNeeded() async {
        guard !isLoadingMore else { return }
        guard currentPage <= totalPages else { return }
        
        isLoadingMore = true
        await loadInitialData()
        isLoadingMore = false
    }
    
    // For SwiftUI's onAppear that can't be async directly
    nonisolated func handleOnAppear() {
        Task { @MainActor in
            await loadMoreIfNeeded()
        }
    }
}
