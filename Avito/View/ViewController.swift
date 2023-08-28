//
//  ViewController.swift
//  Avito
//
//  Created by Гаджи Герейакаев on 25.08.2023.
//

import UIKit


class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private struct CollectionViewConstants {
        static let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        static let minimumInteritemSpacing: CGFloat = 10
        static let minimumLineSpacing: CGFloat = 10
        static let numberOfItemsPerRow: CGFloat = 2
    }
    
    //MARK: Variables
    
    private let dataManager = ItemDataManager.shared
    private var data: [ItemMenuCardModel] = []
    
    private var state: ViewState = .loading {
        didSet {
            updateCollectionViewUI(for: state)
        }
    }
    
    private lazy var itemWidth: CGFloat = {
        let paddingSpace = CollectionViewConstants.sectionInsets.left +
        CollectionViewConstants.sectionInsets.right +
        (CollectionViewConstants.minimumInteritemSpacing * (CollectionViewConstants.numberOfItemsPerRow - 1))
        return (view.frame.width - paddingSpace) / CollectionViewConstants.numberOfItemsPerRow
    }()
    
    private lazy var itemSize: CGSize = {
        return CGSize(width: itemWidth, height: itemWidth * 1.7)
    }()
    
    //MARK: Views
    
    private let collectionViewErrorLabel: UILabel = {
        let label = UILabel()
        label.text = "Произошла ошибка"
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private let collectionViewActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.isHidden = true
        return indicator
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = CollectionViewConstants.sectionInsets
        layout.minimumInteritemSpacing = CollectionViewConstants.minimumInteritemSpacing
        layout.minimumLineSpacing = CollectionViewConstants.minimumLineSpacing
        layout.itemSize = itemSize
        
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.register(CustomCell.self, forCellWithReuseIdentifier: "CustomCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(collectionViewErrorLabel)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionViewErrorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionViewErrorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        state = .loading
        
        dataManager.fetchMenuItems { [unowned self] menuData in
            self.data = menuData
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.state = .content
            }
        }
    }
    
    private func updateCollectionViewUI(for state: ViewState) {
        switch state {
        case .loading:
            DispatchQueue.main.async {
                self.collectionViewActivityIndicator.startAnimating()
                self.collectionView.isHidden = true
                self.collectionViewErrorLabel.isHidden = true
            }
            
            
        case .content:
            DispatchQueue.main.async {
                self.collectionViewActivityIndicator.stopAnimating()
                self.collectionView.isHidden = false
                self.collectionViewErrorLabel.isHidden = true
            }
            
            
        case .error:
            DispatchQueue.main.async {
                self.collectionViewActivityIndicator.stopAnimating()
                self.collectionViewErrorLabel.isHidden = false
                self.collectionView.isHidden = true
            }
            
            
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as? CustomCell else {
            return UICollectionViewCell()
        }
        cell.item = data[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailViewController = DetailViewController()
        let selectedItem = data[indexPath.row]
        detailViewController.itemId = selectedItem.id
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
