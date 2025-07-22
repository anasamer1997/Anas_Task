//
//  searchViewModel.swift
//  AnasTask
//
//  Created by Anas Amer on 27/01/1447 AH.
//

import Foundation
import Combine

class SearchViewModel:ObservableObject{
    private let searchNetworkClient = NetworkClient(baseURL: URL(string: "https://mock.apidog.com/m1/735111-711675-default/")!)
    private var cancellables = Set<AnyCancellable>()
    private let searchSubject = PassthroughSubject<String, Never>()

    @Published var isSearching = false
    @Published var searchResults: [Content] = []
    @Published var errorMessage: String?
 
    private func setupSearchPublisher() {
        searchSubject
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                self.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    func search(query: String) {
        // Just send the query to the subject, the debounce will handle the timing
        searchSubject.send(query)
    }
    
    func clearSearch() {
        searchResults = []
        isSearching = false
        errorMessage = nil
    }
    
    func performSearch(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        
        
        searchNetworkClient.execute(SampleAPI.SearchMedia(query: ""))
            .sink { [weak self] completion in
                self?.isSearching = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = error.errorDescription
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
               
                self.searchResults = response.sections.flatMap { $0.content }
            }
            .store(in: &cancellables)
    }
}
