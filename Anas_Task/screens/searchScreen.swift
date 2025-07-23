//
//  searchScreen.swift
//  AnasTask
//
//  Created by Anas Amer on 27/01/1447 AH.
//

import Foundation
import UIKit
import Combine
import SwiftUI

class SearchViewController: UIViewController {

    
    lazy var viewModel:SearchViewModel = {
        return SearchViewModel()
    }()

    private var cancellables = Set<AnyCancellable>()
    private let searchController = UISearchController(searchResultsController: nil)
    private let mediaCV = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupViewModelBindings()
        
    }

    private func setupViewModelBindings() {
        viewModel.onSearchResultsUpdated = { [weak self] result in
            guard let self = self else { return }
            if result != nil{
                DispatchQueue.main.async {
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
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    private func setupUI() {
       
        view.backgroundColor = .systemBackground
        title = "Search"
        mediaCV.delegate = self
        mediaCV.dataSource = self
        mediaCV.register(MediaCollectionViewCell.self, forCellWithReuseIdentifier:MediaCollectionViewCell.reuseIdentifier)
        
        view.addSubview(mediaCV)
        mediaCV.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mediaCV.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mediaCV.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mediaCV.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mediaCV.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search podcasts, episodes..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}
extension UICollectionView {
    func showLoadingIndicator() {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.startAnimating()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 50)
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 50))
        footerView.addSubview(activityIndicator)
        
        self.backgroundView = footerView
    }
    
    func hideLoadingIndicator() {
        self.backgroundView = nil
    }
}
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        if query != ""{
            viewModel.search(query: query)
        }
       
    }
}


extension SearchViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.searchResults?.sections.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.searchResults?.sections[section].content.count ?? 0
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 16
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 16
//    }
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//           if indexPath.row == viewModel.numberOfProducts - 1 {
//               loadingIndicator.startAnimating()
//               viewModel.fetchProducts()
//           }
//       }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
                  withReuseIdentifier: MediaCollectionViewCell.reuseIdentifier,
                  for: indexPath
              ) as! MediaCollectionViewCell
      
        cell.configure(with: viewModel.searchResults?.sections[indexPath.row].content ?? [], style: viewModel.searchResults?.sections[indexPath.row].type ?? "")
        return cell
    }

}


class MediaCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ProductCollectionViewCell"
    private var hostingController: UIHostingController<AnyView>?
    
    func configure(with content: [SearchContent], style: String) {
        // Remove any existing hosting controller
        hostingController?.view.removeFromSuperview()
        
        // Create the appropriate SwiftUI view based on style
        let rootView: AnyView
        switch style {
        case "square":
            rootView = AnyView(BilateralGridView(content: content))
        case "2_lines_grid":
            rootView = AnyView(TileGridView(content: content))
        case "big_square":
            rootView = AnyView(DefaultGridView(content:content))
        default:
            rootView = AnyView(DefaultGridView(content:content))
        }
        
        // Create and configure the hosting controller
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.backgroundColor = .clear
        
        // Add the hosting controller's view to the cell
        contentView.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        self.hostingController = hostingController
    }
}

