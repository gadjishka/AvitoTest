//
//  CustomCollectionViewCell.swift
//  Avito
//
//  Created by Гаджи Герейакаев on 25.08.2023.
//

import UIKit

class CustomCell: UICollectionViewCell {
    
    private struct CellLayoutConstants {
        static let cornerRadius: CGFloat = 7.0
        static let contentSpacing: CGFloat = 5.0
        static let labelWidthMultiplier: CGFloat = 0.8
        static let imageAspectRatio: CGFloat = 1.0 / 1.0 // Измените соответственно
    }

    //MARK: Variables
    
    var item: ItemMenuCardModel? {
        didSet {
            guard let item = item else { return }
            loadImage(from: item.image_url)
            loadTitles(item)
        }
    }

    //MARK: Views
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = CellLayoutConstants.cornerRadius
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label.withAlphaComponent(0.5)
        return label
    }()
    
    private let createdDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label.withAlphaComponent(0.5)
        return label
    }()
    
    private lazy var labels: [UILabel] = [titleLabel, priceLabel, locationLabel, createdDateLabel]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Functions for views
    
    private func setupViews() {
        contentView.addSubview(imageView)
        
        for (index, label) in labels.enumerated() {
            contentView.addSubview(label)
            label.setContentHuggingPriority(.required, for: .vertical)
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellLayoutConstants.contentSpacing),
                label.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: CellLayoutConstants.labelWidthMultiplier)
            ])
            
            if index == 0 {
                label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: CellLayoutConstants.contentSpacing).isActive = true
            } else {
                label.topAnchor.constraint(equalTo: labels[index - 1].bottomAnchor, constant: CellLayoutConstants.contentSpacing).isActive = true
            }
            
            if index == labels.count - 1 {
                label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellLayoutConstants.contentSpacing).isActive = true
            }
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellLayoutConstants.contentSpacing),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: CellLayoutConstants.imageAspectRatio)
        ])
    }
    
    
    //MARK: Load data
    
    private func loadTitles(_ item: ItemMenuCardModel) {
        titleLabel.text = item.title
        priceLabel.text = item.price
        locationLabel.text = item.location
        createdDateLabel.text = item.created_date
    }
    
    private func loadImage(from urlString: String) {
        ImageLoader.shared.loadImageFromURL(from: urlString) { [weak self] image in
            if let image = image {
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
            } else {
                print("Image is nil")
            }
        }
    }
}
