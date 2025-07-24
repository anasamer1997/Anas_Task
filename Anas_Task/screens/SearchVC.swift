//
//  SearchVC.swift
//  Anas_Task
//
//  Created by anas amer on 23/07/2025.
//

import Foundation
import UIKit
import Combine

class SearchScreen: UIViewController {
    
    lazy var viewModel:SearchViewModel = {
        return SearchViewModel()
    }()
    
    //    @IBOutlet weak var mediaCV: UICollectionView!
    private var mediaCV: UICollectionView!
    private var cancellables = Set<AnyCancellable>()
    private let searchController = UISearchController(searchResultsController: nil)
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemBlue
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeCollectionView()
        setupUI()
        setupViewModelBindings()
        setupCollectionViewLayout()
    }
    private func initializeCollectionView() {
        let layout = UICollectionViewFlowLayout()
        mediaCV = UICollectionView(frame: .zero, collectionViewLayout: layout)
        mediaCV.backgroundColor = .systemBackground
        view.addSubview(mediaCV)
    }
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    private func setupViewModelBindings() {
        viewModel.onSearchingStateChanged = { [weak self] isSearch in
              DispatchQueue.main.async {
                  if isSearch{
                      self?.activityIndicator.startAnimating()
                  }else{
                      self?.activityIndicator.stopAnimating()
                  }
                 
              }
          }
          
        viewModel.onSearchResultsUpdated = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
               
                if result != nil{
                    self.mediaCV.reloadData()
                }
            }
            
        }
        
        viewModel.onErrorMessageReceived = { [weak self] message in
            guard let message = message else { return }
            DispatchQueue.main.async {
              
                self?.showErrorAlert(message: message)
            }
        }
    }
    private func setupUI() {
        title = "Search"
        mediaCV.delegate = self
        mediaCV.dataSource = self
        mediaCV.register(PortraitCollectionViewCell.self, forCellWithReuseIdentifier:"PortraitCell")
        mediaCV.register(TwoLineGridCollectionViewCell.self, forCellWithReuseIdentifier:"TwoLineGridCell")
        mediaCV.register(BigSquareCollectionViewCell.self, forCellWithReuseIdentifier:"BigSquareCell")
        mediaCV.register(CollectionViewHeaderReusableView.self,
                         forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                         withReuseIdentifier: "CollectionViewHeaderReusableView")
        mediaCV.translatesAutoresizingMaskIntoConstraints = false
        mediaCV.backgroundView?.backgroundColor = .orange
        NSLayoutConstraint.activate([
            mediaCV.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mediaCV.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mediaCV.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mediaCV.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search podcasts, episodes..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    private func setupCollectionViewLayout() {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, environment) -> NSCollectionLayoutSection? in
            guard let self = self,
                  let sectionType = self.viewModel.searchResults?.sections[sectionIndex].type else {
                return nil
            }
            
            let section: NSCollectionLayoutSection
            
            switch sectionType {
            case "square":
                section = CompositionalLayout.createHorizontalScrollingLayout()
            case "big_square":
                section = CompositionalLayout.createBigCellLayout()
            case "2_line_grid":
                section = CompositionalLayout.createTwoCellGridLayout()
            default:
                //                section = CompositionalLayout.createHorizontalScrollingLayout()
                section = CompositionalLayout.createTwoCellGridLayout()
            }
            
            // Add header to all sections
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(50))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        
        mediaCV.collectionViewLayout = layout
    }
}

extension SearchScreen: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text , !query.isEmpty else { return }
        viewModel.search(query: query)
        
    }
}
extension SearchScreen: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  viewModel.searchResults?.sections.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return viewModel.searchResults?.sections[section].content.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = viewModel.searchResults?.sections[indexPath.section] else {
            return UICollectionViewCell()
        }
        
        let content = section.content[indexPath.row]// is he going to loop on each item in content for this section
        
        switch section.type {
        case "square":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PortraitCell", for: indexPath) as! PortraitCollectionViewCell
            cell.configure(with: content)
            return cell
            
        case "2_line_grid":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TwoLineGridCell", for: indexPath) as! TwoLineGridCollectionViewCell
            cell.configure(with: content)
            return cell
            
            // Add more cases for other section types
            
        default:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BigSquareCell", for: indexPath) as! BigSquareCollectionViewCell
//            cell.configure(with: content)
//            return cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TwoLineGridCell", for: indexPath) as! TwoLineGridCollectionViewCell
            cell.configure(with: content)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CollectionViewHeaderReusableView", for: indexPath) as! CollectionViewHeaderReusableView
            header.setup(viewModel.searchResults?.sections[indexPath.section].name ?? "")
            return header
        default:
            return UICollectionReusableView()
        }
    }
}
extension CompositionalLayout {
    
    // 1. Horizontal Scrolling Layout (for "square" type)
    static func createHorizontalScrollingLayout() -> NSCollectionLayoutSection {
        // Item size
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = createItem(width: itemSize.widthDimension,
                              height: itemSize.heightDimension,
                              spacing: NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
        
        // Group size (horizontal scrolling items)
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(160),
                                               heightDimension: .absolute(200))
        let group = createGroup(alignment: .horizontal,
                                width: groupSize.widthDimension,
                                height: groupSize.heightDimension,
                                items: [item])
        
        // Section with horizontal scrolling
        return craeteSection(group: group,
                             scrollingBehavor: .continuous,
                             groupSpcaing: 16,
                             contentPaddint: NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }
    
    // 2. Big Cell Layout (200x200)
    static func createBigCellLayout() -> NSCollectionLayoutSection {
        // Item size
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .absolute(200))
        let item = createItem(width: itemSize.widthDimension,
                              height: itemSize.heightDimension,
                              spacing: NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
        
        // Group size (single big item)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(200))
        let group = createGroup(alignment: .vertical,
                                width: groupSize.widthDimension,
                                height: groupSize.heightDimension,
                                item: item,
                                count: 2)
        
        // Section with vertical scrolling
        return craeteSection(group: group,
                             scrollingBehavor: .none,
                             groupSpcaing: 0,
                             contentPaddint: NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
    }
    
    // 3. Two-Cell Grid Layout (horizontal)
    static func createTwoCellGridLayout() -> NSCollectionLayoutSection {
        // Each item takes full width and half the height (since we'll have 2 items stacked)
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                            heightDimension: .fractionalHeight(0.5))
        let item = createItem(width: itemSize.widthDimension,
                             height: itemSize.heightDimension,
                             spacing: NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        
        // Group contains 2 items stacked vertically
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), // 90% of width
                                             heightDimension: .fractionalHeight(0.3)) // Half of visible height
        let group = createGroup(alignment: .vertical,
                              width: groupSize.widthDimension,
                              height: groupSize.heightDimension,
                              items: [item, item]) // Two items stacked
        
        // Section with horizontal scrolling
        return craeteSection(group: group,
                            scrollingBehavor: .groupPaging, // or .continuous for smoother scrolling
                            groupSpcaing: 5,
                            contentPaddint: NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
    }
}
