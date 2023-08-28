//
//  LoadData.swift
//  Avito
//
//  Created by Гаджи Герейакаев on 25.08.2023.
//
import Foundation

class ItemDataManager {
    static let shared = ItemDataManager()
    
    private init() {}
    
    // parse JSON to dict
    
    private func parseJSONFromURL(urlString: String, completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "InvalidURL", code: 0, userInfo: nil))
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let jsonData = data else {
                completion(nil, NSError(domain: "NoData", code: 0, userInfo: nil))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                
                guard let jsonArray = json else {
                    completion(nil, NSError(domain: "InvalidJSON", code: 0, userInfo: nil))
                    return
                }
                
                // Получение массива значений из словаря JSON
                if let array = jsonArray.values.first as? [[String: Any]] {
                    completion(array, nil)
                } else {
                    completion(nil, NSError(domain: "InvalidJSON", code: 0, userInfo: nil))
                }
                
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
    
    
    // parse dict to ItemMenuCardModel
    
    func fetchMenuItems(completion: @escaping ([ItemMenuCardModel]) -> Void) {
        let urlString = "https://www.avito.st/s/interns-ios/main-page.json"
        parseJSONFromURL(urlString: urlString) { (menuJSONArray, error) in
            if let error = error {
                print("Error parsing menu JSON: \(error.localizedDescription)")
                return
            }
            
            var menuData: [ItemMenuCardModel] = []
            
            if let menuJSONArray = menuJSONArray {
                DispatchQueue.main.async {
                    // Обработка массива категорий
                    for menuDict in menuJSONArray {
                        if let id = menuDict["id"] as? String,
                           let title = menuDict["title"] as? String,
                           let price = menuDict["price"] as? String,
                           let location = menuDict["location"] as? String,
                           let image_url = menuDict["image_url"] as? String,
                           let created_date = menuDict["created_date"] as? String
                        {
                            
                            
                            let menuItem = ItemMenuCardModel(id: id, title: title, price: price, location: location, image_url: image_url, created_date: created_date)
                            menuData.append(menuItem)
                        }
                    }
                    
                    completion(menuData)
                }
            }
        }
    }
    
    
    //parse JSON to ItemDetailCardModel
    
    func fetchItemDetail(itemId: String, completion: @escaping (Result<ItemDetailCardModel, Error>) -> Void) {
        
        let urlString = "https://www.avito.st/s/interns-ios/details/\(itemId).json"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let itemDetailCard = try decoder.decode(ItemDetailCardModel.self, from: data)
                completion(.success(itemDetailCard))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }    
}
