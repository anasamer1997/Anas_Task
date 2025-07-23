//
//  searchViewModel.swift
//  AnasTask
//
//  Created by Anas Amer on 27/01/1447 AH.
//

import Foundation
import Combine

class SearchViewModel {
    private let searchNetworkClient = NetworkClient(baseURL: URL(string: "https://mock.apidog.com/m1/735111-711675-default/")!)
    private var cancellables = Set<AnyCancellable>()
    private let searchSubject = PassthroughSubject<String, Never>()
    
    // Closure-based state handlers
    var onSearchResultsUpdated: ((SearchResponse?) -> Void)?
    var onSearchingStateChanged: ((Bool) -> Void)?
    var onErrorMessageReceived: ((String?) -> Void)?
    
    private var isSearching = false {
        didSet {
            onSearchingStateChanged?(isSearching)
        }
    }
    
    var searchResults: SearchResponse? {
        didSet {
            onSearchResultsUpdated?(searchResults)
        }
    }
    
    private var errorMessage: String? {
        didSet {
            onErrorMessageReceived?(errorMessage)
        }
    }

    init(){
        setupSearchPublisher()
    }
    private func setupSearchPublisher() {
        searchSubject
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isSearching = true
            })
            .flatMap { [weak self] query -> AnyPublisher<SearchResponse, Never> in
                guard let self = self, !query.isEmpty else {
                    return Just(SearchResponse(sections: []))
                                       .eraseToAnyPublisher()
                }
                
                return self.searchNetworkClient.execute(SampleAPI.SearchMedia())
                    .map { $0 }
                    .catch { [weak self] error -> Just<SearchResponse> in
                        DispatchQueue.main.async {
                            self?.errorMessage = error.errorDescription
                        }
                        return Just(SearchResponse(sections: []))
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                
                self?.searchResults = results
                self?.isSearching = false
            }
            .store(in: &cancellables)
    }
    
    func search(query: String) {
        searchSubject.send(query)
    }
    
    func clearSearch() {
        searchSubject.send("")
        searchResults =  SearchResponse(sections: [])
        isSearching = false
        errorMessage = nil
    }
}
