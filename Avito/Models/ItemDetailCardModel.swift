//
//  ItemCardModel.swift
//  Avito
//
//  Created by Гаджи Герейакаев on 25.08.2023.
//

import Foundation

class ItemDetailCardModel: Hashable, Codable, Identifiable {
    var id: String
    var title: String
    var price: String
    var location: String
    var image_url: String
    var created_date: String
    var description: String
    var email: String
    var phone_number: String
    var address: String
    
    init(id: String, title: String, price: String, location: String, image_url: String, created_date: String, description: String, email: String, phone_number: String, address: String) {
        self.id = id
        self.title = title
        self.price = price
        self.location = location
        self.image_url = image_url
        self.created_date = created_date
        self.description = description
        self.email = email
        self.phone_number = phone_number
        self.address = address
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(price)
        hasher.combine(location)
        hasher.combine(image_url)
        hasher.combine(created_date)
        hasher.combine(description)
        hasher.combine(email)
        hasher.combine(phone_number)
        hasher.combine(address)
    }

    static func == (lhs: ItemDetailCardModel, rhs: ItemDetailCardModel) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title && lhs.price == rhs.price && lhs.location == rhs.location && lhs.image_url == rhs.image_url && lhs.created_date == rhs.created_date && lhs.description == rhs.description && lhs.email == rhs.email && lhs.phone_number == rhs.phone_number && lhs.address == rhs.address
    }

    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id, title, price, location, image_url, created_date, description, email, phone_number, address
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        price = try container.decode(String.self, forKey: .price)
        location = try container.decode(String.self, forKey: .location)
        image_url = try container.decode(String.self, forKey: .image_url)
        created_date = try container.decode(String.self, forKey: .created_date)
        description = try container.decode(String.self, forKey: .description)
        email = try container.decode(String.self, forKey: .email)
        phone_number = try container.decode(String.self, forKey: .phone_number)
        address = try container.decode(String.self, forKey: .address)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(price, forKey: .price)
        try container.encode(location, forKey: .location)
        try container.encode(image_url, forKey: .image_url)
        try container.encode(created_date, forKey: .created_date)
        try container.encode(description, forKey: .description)
        try container.encode(email, forKey: .email)
        try container.encode(phone_number, forKey: .phone_number)
        try container.encode(address, forKey: .address)
       
    }
}
