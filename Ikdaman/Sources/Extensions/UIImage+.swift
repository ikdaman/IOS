//
//  UIImage+.swift
//  Ikdaman
//
//  Created by 이재혁 on 9/4/25.
//

import UIKit

extension UIImage {
    private static let imageCache = NSCache<NSString, UIImage>()
    
    convenience init?(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        let cacheKey = NSString(string: urlString)
        
        // 캐시된 이미지가 있으면 즉시 반환
        if let cachedImage = UIImage.imageCache.object(forKey: cacheKey) {
            self.init(cgImage: cachedImage.cgImage!)
            return
        }
        
        // 캐시된 이미지가 없으면 백그라운드에서 로딩 시작
        UIImage.loadImageInBackground(from: url, cacheKey: cacheKey)
        
        return nil
    }
    
    private static func loadImageInBackground(from url: URL, cacheKey: NSString) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let image = UIImage(data: data),
                  let response = response as? HTTPURLResponse,
                  (200..<300).contains(response.statusCode) else {
                return
            }
            
            // 캐시에 저장
            UIImage.imageCache.setObject(image, forKey: cacheKey)
        }.resume()
    }
}
