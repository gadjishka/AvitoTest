//
//  ItemMenuCardModel.swift
//  Avito
//
//  Created by Гаджи Герейакаев on 25.08.2023.
//

import Foundation

class ItemMenuCardModel: Hashable, Codable, Identifiable {
    var id: String
    var title: String
    var price: String
    var location: String
    var image_url: String
    var created_date: String
    
    init(id: String, title: String, price: String, location: String, image_url: String, created_date: String) {
        self.id = id
        self.title = title
        
        let numberString = price

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
        self.price = resultString
        self.location = location
        self.image_url = image_url
        self.created_date = created_date
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(price)
        hasher.combine(location)
        hasher.combine(image_url)
        hasher.combine(created_date)
    }

    static func == (lhs: ItemMenuCardModel, rhs: ItemMenuCardModel) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title && lhs.price == rhs.price && lhs.location == rhs.location && lhs.image_url == rhs.image_url && lhs.created_date == rhs.created_date
    }

    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id, title, price, location, image_url, created_date
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        price = try container.decode(String.self, forKey: .price)
        location = try container.decode(String.self, forKey: .location)
        image_url = try container.decode(String.self, forKey: .image_url)
        created_date = try container.decode(String.self, forKey: .created_date)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(price, forKey: .price)
        try container.encode(location, forKey: .location)
        try container.encode(image_url, forKey: .image_url)
        try container.encode(created_date, forKey: .created_date)
    }
}
