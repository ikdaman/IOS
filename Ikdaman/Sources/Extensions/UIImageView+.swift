//
//  UIImageView+.swift
//  Ikdaman
//
//  Created by 이재혁 on 5/18/25.
//

import UIKit

extension UIImageView {
    private static let imageCache = NSCache<NSString, UIImage>()
    
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
