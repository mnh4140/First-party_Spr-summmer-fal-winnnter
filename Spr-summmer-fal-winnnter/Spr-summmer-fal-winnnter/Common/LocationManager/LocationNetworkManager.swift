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
    
    private lazy var apiKey: String? = {
        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let key = plist["KakaoApiKey"] as? String else {
            print("❌ Info.plist에서 KakaoApiKey를 불러오지 못했습니다.")
            return nil
        }
        return key
    }()

    func fetchData<T: Decodable>(url: URL) -> Single<T> {
        return Single.create { single in
            
            // apiKey 옵셔널 언래핑
            guard let apiKey = self.apiKey else {
                return Disposables.create()
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = [
                "Authorization": "KakaoAK \(apiKey)"
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
