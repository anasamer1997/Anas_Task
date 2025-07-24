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
    @State private var selectedType = ""
    
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
            
            VStack{
                TabBarView(tabbarItems: viewModel.contentType,viewModel: viewModel).previewDisplayName("TabBarView")
                if viewModel.isLoading && viewModel.sections.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else {
                    lazyVStackContent()
                }
            }
            
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
            if viewModel.isLoading{
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

struct TabBarView: View {
    var tabbarItems: [String]
    @ObservedObject var viewModel: HomeViewModel

    @State var selectedIndex = 0

    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(tabbarItems.indices, id: \.self) { index in

                        Text(tabbarItems[index])
                            .font(.subheadline)
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                            .foregroundColor(selectedIndex == index ? .white : .black)
                            .background(Capsule().foregroundColor(selectedIndex == index ? .purple : .clear))
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    selectedIndex = index
                                    viewModel.selectedContentType = tabbarItems[index]
                                    viewModel.showNewContentTypeData = true
                                }
                            }
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(25)

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
        case "square" , "queue":
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
