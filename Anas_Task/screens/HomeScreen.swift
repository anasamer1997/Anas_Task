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
            LazyVStack(spacing: 24) {
                ForEach(Array(viewModel.sections.enumerated()), id: \.element.id) { index, section in
                    SectionView(section: section)
                        .onAppear {
                            let threshold = 2 // Start loading when 2 from the end
                            let shouldTrigger = index >= viewModel.sections.count - threshold
                            
                            if shouldTrigger {
                                Task {
                                    await viewModel.shouldLoadPagination()
                                }
                            }
                        }
                }
                
                if viewModel.isLoading  {
                    ProgressView()
                        .frame(maxHeight: .infinity, alignment: .center)
                        .padding()
                }
            }
            .padding(.vertical)
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
            BilateralGridView(content: section.content)
        case "2_lines_grid":
            TileGridView(content: section.content)
        case "big_square":
            DefaultGridView(content: section.content)
        default:
            DefaultGridView(content: section.content)
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
