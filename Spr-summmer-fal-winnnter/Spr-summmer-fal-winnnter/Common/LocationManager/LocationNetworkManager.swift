//
//  network.swift
//  Spr-summmer-fal-winnnter
//
//  Created by NH on 5/22/25.
//

import Foundation
import RxSwift

class LocationNetworkManager {
    static let shared = LocationNetworkManager()
    private init() {}
    
    private let apiKey = "737335414faed8edaaa51e0badb4fb08"

    func fetchData<T: Decodable>(url: URL) -> Single<T> {
        return Single.create { single in
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = [
                "Authorization": "KakaoAK \(self.apiKey)"
            ]
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                let successRange = 200..<300
                
                if let error = error {
                    single(.failure(error))
                    return
                }
                
                guard let response = response as? HTTPURLResponse else { return }
                
                guard successRange.contains(response.statusCode) else { return }
                
                guard let data = data else {
                    let statusCode = response.statusCode
                    single(.failure(NSError(domain: "HTTPError", code: statusCode, userInfo: nil)))
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    single(.success(decoded))
                } catch {
                    single(.failure(error))
                }
            }
            
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
}
