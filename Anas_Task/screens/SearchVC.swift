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



class PortraitCollectionViewCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Image View
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        contentView.addSubview(imageView)
        
        // Title Label
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        contentView.addSubview(titleLabel)
        
        // Subtitle Label
        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 1
        contentView.addSubview(subtitleLabel)
        
        // Layout
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with content: SearchContent) {
        titleLabel.text = content.name
        subtitleLabel.text = "\(content.episodeCount) episodes • \(content.language)"
        
        // Load image (using a helper function or SDWebImage/Kingfisher)
        if let url = URL(string: content.displayImageURL) {
            loadImage(from: url, into: imageView)
        }
    }
    private func loadImage(from url: URL, into imageView: UIImageView) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }.resume()
    }
}
class TwoLineGridCollectionViewCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let metaLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Image View
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        contentView.addSubview(imageView)
        
        // Title Label
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        contentView.addSubview(titleLabel)
        
        // Description Label
        descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2
        contentView.addSubview(descriptionLabel)
        
        // Meta Label
        metaLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        metaLabel.textColor = .tertiaryLabel
        contentView.addSubview(metaLabel)
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = .systemGray6
        // Layout
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        metaLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),

            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            metaLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            metaLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            metaLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            metaLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with content: SearchContent) {
        titleLabel.text = content.name
        descriptionLabel.text = content.description
        metaLabel.text = "\(content.episodeCount) episodes • \(content.duration) min"
        
        if let url = URL(string: content.avatarURL) {
            loadImage(from: url, into: imageView)
        }
    }
    
    private func loadImage(from url: URL, into imageView: UIImageView) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }.resume()
    }
}
class BigSquareCollectionViewCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let badgeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Image View
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        contentView.addSubview(imageView)
        
        // Gradient Overlay
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.7).cgColor]
        gradientLayer.locations = [0.6, 1.0]
        imageView.layer.addSublayer(gradientLayer)
        
        // Title Label
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)
        
        // Description Label
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        descriptionLabel.textColor = .white.withAlphaComponent(0.9)
        descriptionLabel.numberOfLines = 2
        contentView.addSubview(descriptionLabel)
        
        // Badge Label
        badgeLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        badgeLabel.textColor = .white
        badgeLabel.backgroundColor = .systemBlue
        badgeLabel.layer.cornerRadius = 4
        badgeLabel.clipsToBounds = true
        badgeLabel.textAlignment = .center
        contentView.addSubview(badgeLabel)
        
        // Layout
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            badgeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            badgeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            badgeLabel.widthAnchor.constraint(equalToConstant: 60),
            badgeLabel.heightAnchor.constraint(equalToConstant: 24),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -8)
        ])
        
        // Update gradient frame when layout changes
        imageView.layoutIfNeeded()
        gradientLayer.frame = imageView.bounds
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = imageView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = imageView.bounds
        }
    }
    
    func configure(with content: SearchContent) {
        titleLabel.text = content.name
        descriptionLabel.text = content.description
        badgeLabel.text = content.language.uppercased()
        
        if let url = URL(string: content.avatarURL) {
            loadImage(from: url, into: imageView)
        }
    }
    
    private func loadImage(from url: URL, into imageView: UIImageView) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }.resume()
    }
}
class CollectionViewHeaderReusableView: UICollectionReusableView {
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .label
        addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func setup(_ title: String) {
        titleLabel.text = "Section : \(title)"
    }
}
