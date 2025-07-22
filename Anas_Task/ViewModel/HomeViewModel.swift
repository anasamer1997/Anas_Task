//
//  HomeViewModel.swift
//  AnasTask
//
//  Created by Anas Amer on 27/01/1447 AH.
//

import Foundation
import Combine
// Example ViewModel using the network layer
class HomeViewModel: ObservableObject {
    private let networkClient = NetworkClient(baseURL: URL(string: "https://api-v2-b2sit6oh3a-uc.a.run.app/")!)
    private var cancellables = Set<AnyCancellable>()
  
    
    @Published var sections: [Section] = []


    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    private var currentPage = 1
    private var totalPages = -1
  
    
   
    
 
    
    @MainActor
    func loadInitialData() async {
        isLoading = true
        errorMessage = nil

        networkClient.execute(SampleAPI.GetMedia(page: currentPage))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = error.errorDescription
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
             
                sections.append(contentsOf: response.sections)
                totalPages = response.pagination.totalPages
                currentPage += 1
            }
            .store(in: &cancellables)
    }
    
    func refresh() async {
        currentPage = 1
        totalPages = -1
        sections.removeAll()
        
        await loadInitialData()
    }
    @MainActor
    func shouldLoadPagination() async {
        guard !isLoadingMore else { return }
        guard currentPage < totalPages else { return }

        isLoadingMore = true
        await loadInitialData()
        isLoadingMore = false
    }

}
