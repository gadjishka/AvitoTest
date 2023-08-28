//
//  DetailsViewController.swift
//  Avito
//
//  Created by Гаджи Герейакаев on 25.08.2023.
//

import UIKit


class DetailViewController: UIViewController {
    
    private struct LayoutConstants {
        static let imageAspectRatio: CGFloat = 1.0 / 0.8
        static let leadingConstraint: CGFloat = 10
        static let buttonCornerRadius: CGFloat = 10
        static let buttonHeight: CGFloat = 40
    }
    
    
    
    //MARK: Variablse
    var itemId: String?
    
    private var item: ItemDetailCardModel? = nil {
        didSet {
            if let _ = item {
                loadImage()
                loadTitles()
            }
        }
    }
    
    private var state: ViewState = .loading {
        didSet {
            updateUI(for: state)
        }
    }
    
    //MARK: Views
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 22)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 27, weight: .semibold)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let descriptionNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private let createdDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label.withAlphaComponent(0.5)
        return label
    }()
    
    private let adNumberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label.withAlphaComponent(0.5)
        return label
    }()
    
    private let callButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Позвонить", for: .normal)
        button.backgroundColor = UIColor(red: 0.039, green: 0.817, blue: 0.361, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let emailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Написать", for: .normal)
        button.backgroundColor = UIColor(red: 0, green: 0.671, blue: 1.0, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Произошла ошибка загрузки данных"
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true // Скрываем его по умолчанию
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        setupScrollView()
        setupButtons()
        setupConstraints()
        
        
        if let itemId = itemId {
            fetchItemDetails(itemId: itemId)
            loadData()
        }
    }
    
    //MARK: Functions for views
    
    private func updateUI(for state: ViewState) {
        switch state {
        case .loading:
            // Показываем индикатор загрузки на главном потоке
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
                self.scrollView.isHidden = true
                self.errorLabel.isHidden = true
            }
            
            
        case .content:
            // Переключаемся на главный поток для остановки индикатора загрузки
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.scrollView.isHidden = false
                self.errorLabel.isHidden = true
            }
            
            
        case .error:
            // Переключаемся на главный поток для обновления UI
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.errorLabel.isHidden = false
                self.scrollView.isHidden = true
            }
            
            
        }
    }
    
    
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .label
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonTapped))
        let heartButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(heartButtonTapped))
        let cartButton = UIBarButtonItem(image: UIImage(systemName: "cart"), style: .plain, target: self, action: #selector(cartButtonTapped))
        navigationItem.rightBarButtonItems = [cartButton, heartButton, shareButton]
    }
    
    private func setupScrollView() {
        scrollView.backgroundColor = .systemBackground
        scrollView.addSubview(imageView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(priceLabel)
        scrollView.addSubview(createdDateLabel)
        scrollView.addSubview(descriptionLabel)
        scrollView.addSubview(callButton)
        scrollView.addSubview(addressLabel)
        scrollView.addSubview(emailButton)
        scrollView.addSubview(descriptionNameLabel)
        scrollView.addSubview(adNumberLabel)
        
        view.addSubview(scrollView)
        view.addSubview(errorLabel)
    }
    
    private func setupButtons() {
        let commonButtonAttributes: (UIButton) -> Void = { button in
            
            button.layer.cornerRadius = LayoutConstants.buttonCornerRadius
            button.setTitleColor(.white, for: .normal)
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            button.translatesAutoresizingMaskIntoConstraints = false
        }
        
        commonButtonAttributes(callButton)
        commonButtonAttributes(emailButton)
        callButton.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
        emailButton.addTarget(self, action: #selector(emailButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        let imageAspectRatio: CGFloat = 1.0 / 0.8
        let leadingConstraint: CGFloat = 10
        
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.topAnchor, constant: 0),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0 / imageAspectRatio),
            
            priceLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15),
            priceLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: leadingConstraint),
            
            titleLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 2),
            titleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: leadingConstraint),
            titleLabel.widthAnchor.constraint(lessThanOrEqualTo: scrollView.widthAnchor, multiplier: 0.8),
            
            addressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            addressLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: leadingConstraint),
            
            callButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: leadingConstraint), // Определяет половину расстояния между кнопками
            callButton.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 30),
            callButton.trailingAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: -5),
            
            emailButton.leadingAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: 5),
            emailButton.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 30),
            emailButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -leadingConstraint), // Определяет половину расстояния между кнопками
            
            descriptionNameLabel.topAnchor.constraint(equalTo: emailButton.bottomAnchor, constant: 20),
            descriptionNameLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: leadingConstraint),
            titleLabel.widthAnchor.constraint(lessThanOrEqualTo: scrollView.widthAnchor, multiplier: 0.8),
            
            descriptionLabel.topAnchor.constraint(equalTo: descriptionNameLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: leadingConstraint),
            descriptionLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -10), // Выравнивание правой границы на 10 пунктов от правой границы контейнера
            
            
            
            adNumberLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            adNumberLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: leadingConstraint),
            
            createdDateLabel.topAnchor.constraint(equalTo: adNumberLabel.bottomAnchor, constant: 5),
            createdDateLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: leadingConstraint),
            createdDateLabel.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor, constant: -20)
        ])
        
        errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
    }
    
    
    
    //MARK: Functions for buttons
    
    @objc private func shareButtonTapped() {
        // Создание экземпляра UIActivityViewController
        if let item = item { // Предполагается, что у вас есть доступ к модели данных (item)
            let textToShare = item.title
            let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
            
            // Подсказка: Вы можете ограничить доступные типы активностей, добавив их в массив `excludedActivityTypes`
            // activityViewController.excludedActivityTypes = [.airDrop, .addToReadingList]
            
            // Отображение UIActivityViewController
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @objc private func heartButtonTapped() {
        if let heartButton = navigationItem.rightBarButtonItems?[1] {
            if let currentImage = heartButton.image {
                if currentImage == UIImage(systemName: "heart") {
                    let newImage = UIImage(systemName: "heart.fill")
                    let coloredImage = newImage?.withTintColor(.red, renderingMode: .alwaysOriginal)
                    heartButton.image = coloredImage
                } else {
                    let newImage = UIImage(systemName: "heart")
                    heartButton.image = newImage
                }
            }
        }
    }
    
    @objc private func cartButtonTapped() {
        // Логика для кнопки "Корзина"
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    
    @objc private func callButtonTapped() {
        guard let phoneNumber = item?.phone_number, !phoneNumber.isEmpty else {
            print("Phone number is empty or invalid")
            return
        }
        
        let cleanedPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let phoneURL = URL(string: "tel:\(cleanedPhoneNumber)") {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        }
        
    }
    
    @objc private func emailButtonTapped() {
        guard let email = item?.email, !email.isEmpty else {
            print("Email is empty or invalid")
            return
        }
        
        if let emailURL = URL(string: "mailto:\(email)") {
            if UIApplication.shared.canOpenURL(emailURL) {
                UIApplication.shared.open(emailURL, options: [:], completionHandler: nil)
            } else {
                print("Cannot open email app")
            }
        }
    }
    
    
    //MARK: Load data
    
    private func fetchItemDetails(itemId: String) {
        state = .loading
        
        ItemDataManager.shared.fetchItemDetail(itemId: itemId) { result in
            switch result {
            case .success(let itemDetailCard):
                self.item = itemDetailCard
                self.state = .content
            case .failure(let error):
                print("Error parsing item details: \(error)")
                self.state = .error
            }
        }
    }
    
    
    private func loadData() {
        loadImage()
        loadTitles()
    }
    
    private func loadImage() {
        guard let item = item else { return }
        ImageLoader.shared.loadImageFromURL(from: item.image_url) { image in
            if let image = image {
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            } else {
                print("Image is nil")
            }
        }
    }
    
    private func loadTitles() {
        guard let item = item else { return }
        
        let numberString = item.price
        
        // Удаление пробелов и символов валюты
        let cleanedString = numberString.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ru_RU") // Используйте свою локализацию
        
        var resultString = ""
        
        if let number = formatter.number(from: cleanedString), let formattedString = formatter.string(from: number) {
            let currencySymbol = (numberString as NSString).replacingOccurrences(of: "[0-9]", with: "", options: .regularExpression, range: NSRange(location: 0, length: numberString.count))
            resultString = formattedString + " " + currencySymbol
        }
        
        
        DispatchQueue.main.async {
            self.titleLabel.text = item.title
            self.priceLabel.text = resultString
            self.createdDateLabel.text = item.created_date
            self.descriptionNameLabel.text = "Описание"
            self.descriptionLabel.text = item.description
            self.addressLabel.text = item.location + ", " + item.address
            self.adNumberLabel.text = "Объявление №\(item.id)"
        }
    }
    
    
}
