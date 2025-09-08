//
//  UIImageView+.swift
//  Ikdaman
//
//  Created by 이재혁 on 5/18/25.
//

import UIKit

extension UIImageView {
    private static let imageCache = NSCache<NSString, UIImage>()
    
    func setImage(from urlString: String, placeholder: UIImage? = nil) {
        // 먼저 캐시된 이미지나 placeholder 설정
        self.image = ImageCache.cached(urlString) ?? placeholder
        
        // 캐시에 없으면 로딩해서 업데이트
        if ImageCache.cached(urlString) == nil {
            ImageCache.load(urlString) { [weak self] loadedImage in
                if let image = loadedImage {
                    self?.image = image
                }
            }
        }
    }
    
    func loadImage(from urlString: String, placeholder: UIImage? = nil) {
        self.image = placeholder
        
        guard let url = URL(string: urlString) else {
            print("잘못된 URL 정보: \(urlString)")
            return
        }
        
        let cacheKey = NSString(string: urlString)
        if let cachedImage = UIImageView.imageCache.object(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        self.addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        activityIndicator.startAnimating()
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                activityIndicator.removeFromSuperview()
                
                if let error = error {
                    print("이미지 다운로드 오류: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200..<300).contains(httpResponse.statusCode) else {
                    print("서버 오류 또는 잘못된 응답")
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    print("유효하지 않은 이미지 데이터")
                    return
                }
                
                UIImageView.imageCache.setObject(image, forKey: cacheKey)
                
                self?.image = image
            }
        }.resume()
    }
    
    func cancelImageLoad() {
        self.subviews.compactMap { $0 as? UIActivityIndicatorView }.forEach { $0.removeFromSuperview() }
    }
}


struct ImageCache {
    private static let cache = NSCache<NSString, UIImage>()
    
    // 캐시된 이미지만 즉시 반환 (동기)
    static func cached(_ urlString: String) -> UIImage? {
        guard URL(string: urlString) != nil else { return nil }
        
        let cacheKey = NSString(string: urlString)
        return cache.object(forKey: cacheKey)
    }
    
    // 이미지 로드 (비동기)
    static func load(_ urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let cacheKey = NSString(string: urlString)
        
        // 캐시된 이미지가 있으면 즉시 반환
        if let cachedImage = cache.object(forKey: cacheKey) {
            completion(cachedImage)
            return
        }
        
        // 캐시된 이미지가 없으면 로딩
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let image = UIImage(data: data),
                  let response = response as? HTTPURLResponse,
                  (200..<300).contains(response.statusCode) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // 캐시에 저장
            cache.setObject(image, forKey: cacheKey)
            DispatchQueue.main.async { completion(image) }
        }.resume()
    }
}
