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

    @IBOutlet weak var mediaCV: UICollectionView!
    private var cancellables = Set<AnyCancellable>()
    private let searchController = UISearchController(searchResultsController: nil)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupViewModelBindings()
        
    }
    private func createProductCVLayout2() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
           
            // SQUARE TYPE
            
//            let item = CompositionalLayout.createItem(width: .fractionalWidth(1), height: .fractionalWidth(0.5),spacing: NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//            let Group = CompositionalLayout.createGroup(alignment: .horizontal, width: .fractionalWidth(1), height: .absolute(200), item: item, count: 1)
//            
//            let section = CompositionalLayout.craeteSection(group: Group, scrollingBehavor: .none, groupSpcaing: 5, contentPaddint: NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//            return section
            
            // Big_square TYPE
            let item = CompositionalLayout.createItem(width: .fractionalWidth(0.8), height: .fractionalHeight(1),spacing: NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            let Group = CompositionalLayout.createGroup(alignment: .horizontal, width: .fractionalHeight(1), height: .fractionalHeight(0.5), item: item, count: 1)
            
            let section = CompositionalLayout.craeteSection(group: Group, scrollingBehavor: .none, groupSpcaing: 5, contentPaddint: NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            return section
         
        }
    }
    

    private func setupViewModelBindings() {
        viewModel.onSearchResultsUpdated = { [weak self] result in
            guard let self = self else { return }
            if result != nil{
                mediaCV.collectionViewLayout = createProductCVLayout2()
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
        title = "Search"
        mediaCV.delegate = self
        mediaCV.dataSource = self
        mediaCV.register(PortraitCollectionViewCell.self, forCellWithReuseIdentifier:"PhotoCell")
        view.addSubview(mediaCV)
        mediaCV.translatesAutoresizingMaskIntoConstraints = false
        mediaCV.backgroundView?.backgroundColor = .orange
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
        guard let query = searchController.searchBar.text , !query.isEmpty else { return }
            viewModel.search(query: query)
       
    }
}


extension SearchViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.searchResults?.sections.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.searchResults?.sections[section].content.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PortraitCollectionViewCell
        
        guard let sections = viewModel.searchResults?.sections else {
            return cell // Return empty cell if data isn't available
        }
        
        // 2. indexPath.row should probably be indexPath.section if you're using sections
        guard indexPath.section < sections.count else {
            return cell
        }
        let section = sections[indexPath.section]
        

        
        // 3. Force casting with as! is dangerous - better to handle the optional properly
        guard let content = section.content as? [SearchContent] else {
            return cell
        }
       
        cell.configure(with: content[indexPath.row])
        return cell
       
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CollectionViewHeaderReusableView", for: indexPath) as! CollectionViewHeaderReusableView
            header.setup(viewModel.searchResults!.sections[indexPath.section].name)
            return header
        default:
            return UICollectionReusableView()
        }
    }

}
final class CollectionViewHeaderReusableView: UICollectionReusableView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setup(_ title: String) {
        titleLabel.text = title
    }
}

final class PortraitCollectionViewCell: UICollectionViewCell {
    
    private let cellImageView: UIImageView = {
         let iv = UIImageView()
         iv.contentMode = .scaleAspectFill
         iv.clipsToBounds = true
         iv.layer.cornerRadius = 8
         iv.backgroundColor = .systemGray5
         iv.translatesAutoresizingMaskIntoConstraints = false
         return iv
     }()
     
     private let cellTitleLbl: UILabel = {
         let label = UILabel()
         label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
         label.textColor = .label
         label.numberOfLines = 1
         label.translatesAutoresizingMaskIntoConstraints = false
         return label
     }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupViews() {
        contentView.addSubview(cellImageView)
        contentView.addSubview(cellTitleLbl)
        
        NSLayoutConstraint.activate([
            cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellImageView.heightAnchor.constraint(equalTo: cellImageView.widthAnchor),
            
            cellTitleLbl.topAnchor.constraint(equalTo: cellImageView.bottomAnchor, constant: 8),
            cellTitleLbl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellTitleLbl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellTitleLbl.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with content: SearchContent) {
        cellTitleLbl.text = content.displayName
        // Load image from URL (in production, use Kingfisher/SDWebImage)
        if let url = URL(string: content.displayImageURL) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.cellImageView.image = image
                    }
                }
            }.resume()
        }
    }
}
