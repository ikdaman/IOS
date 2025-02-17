//
//  URLSession+.swift
//  Ikdaman
//
//  Created by 김창규 on 2/11/25.
//

import Foundation
import RxSwift

extension URLSession {
    func request(_ api: BaseAPI) -> Observable<(data: Data, response: URLResponse)> {
        var request = URLRequest(url: URL(string: api.baseURL + api.path)!)
        request.httpMethod = api.method
        request.allHTTPHeaderFields = api.headers

        return Observable.create { observer in
            let task = self.dataTask(with: request) { data, response, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                if let data = data, let response = response {
                    observer.onNext((data: data, response: response))
                    observer.onCompleted()
                } else {
                    observer.onError(URLError(.badServerResponse))
                }
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
