//
//  BigSquareCollectionViewCell.swift
//  Anas_Task
//
//  Created by Anas Amer on 29/01/1447 AH.
//

import UIKit

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
