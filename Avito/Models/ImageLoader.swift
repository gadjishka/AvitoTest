//
//  ImageLoader.swift
//  Avito
//
//  Created by Гаджи Герейакаев on 25.08.2023.
//

import Foundation
import UIKit

class ImageLoader {
    static let shared = ImageLoader()
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    func loadImageFromURL(from imageUrlString: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache.object(forKey: imageUrlString as NSString) {
            completion(cachedImage)
            return
        }
        
        guard let url = URL(string: imageUrlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error loading image: \(error)")
                DispatchQueue.main.async {
                    // Вернуть заглушку или другое изображение по умолчанию
                    if let placeholderImage = UIImage(systemName: "photo") {
                        completion(placeholderImage)
                    } else {
                        completion(nil)
                    }
                }
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                self?.imageCache.setObject(image, forKey: imageUrlString as NSString)
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    // Вернуть заглушку или другое изображение по умолчанию
                    if let placeholderImage = UIImage(systemName: "photo") {
                        completion(placeholderImage)
                    } else {
                        completion(nil)
                    }
                }
            }
        }.resume()
    }
}



