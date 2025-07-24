//
//  HomeScreen.swift
//  AnasTask
//
//  Created by Anas Amer on 27/01/1447 AH.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    @State private var showSearch = false
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Discover")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showSearch = true
                        }) {
                            Image(systemName: "magnifyingglass")
                        }
                    }
                }
                
                .sheet(isPresented: $showSearch) {
                    SearchVCRepresentable()
                        .edgesIgnoringSafeArea(.all)
                }
        }
    }
    
    private var content: some View {
        ScrollView {
            lazyVStackContent()
        }
        .overlay(
            Group {
                if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        Task{
                            await viewModel.loadInitialData()
                        }
                    }
                }
            }
        )
        .task {
            Task{
                if viewModel.sections.isEmpty {
                    await viewModel.loadInitialData()
                }
               
            }
        }
        .refreshable {
            Task{
                await viewModel.refresh()
            }
            
        }
    }
    
    @ViewBuilder
    private func lazyVStackContent() -> some View {
        LazyVStack(spacing: 24) {
            // 2. Extract section rows to another function
            sectionRows()
            
            // 3. Extract loading indicator to a separate view
            if viewModel.isLoading {
                loadingIndicator()
            }
        }
        .padding(.vertical)
    }

    @ViewBuilder
    private func sectionRows() -> some View {
        ForEach(Array(viewModel.sections.enumerated()), id: \.element.id) { index, section in
            SectionView(section: section)
                .onAppear {
                    checkPaginationThreshold(index: index)
                }
        }
    }

    private func checkPaginationThreshold(index: Int) {
        let threshold = 2 // Start loading when 2 from the end
        let shouldTrigger = index >= viewModel.sections.count - threshold
        
        if shouldTrigger {
            Task {
                await viewModel.loadMoreIfNeeded()
            }
        }
    }

    private func loadingIndicator() -> some View {
        ProgressView()
            .frame(maxHeight: .infinity, alignment: .center)
            .padding()
    }
}

struct SectionView: View {
    let section: Section
    init(section: Section) {
        self.section = section
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.name)
                .font(.title2.bold())
                .padding(.horizontal)
            sectionContent
        }
    }
    @ViewBuilder
    private var sectionContent: some View {
        switch section.type {
        case "square":
            SquareItemsView(content: section.content)
        case "2_lines_grid":
            TwoItemsGrid(content: section.content)
        case "big_square":
            BigSquareItemsView(content: section.content)
        default:
            BigSquareItemsView(content: section.content)
        }
    }
}

struct SearchVCRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let searchVC = SearchScreen()
        let navController = UINavigationController(rootViewController: searchVC)
        return navController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update if needed
    }
}

#Preview {
    HomeView()
}
