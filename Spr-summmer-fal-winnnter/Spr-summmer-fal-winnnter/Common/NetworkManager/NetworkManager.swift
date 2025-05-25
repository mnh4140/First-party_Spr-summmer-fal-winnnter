//
//  NetworkManager.swift
//  Spr-summmer-fal-winnnter
//
//  Created by NH on 5/21/25.
//

import Foundation
import Alamofire
import UIKit
import RxSwift

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    private lazy var apiKey: String? = {
        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let key = plist["OpenWeatherApiKey"] as? String else {
            print("❌ Info.plist에서 OpenWeatherApiKey를 불러오지 못했습니다.")
            return nil
        }
        return key
    }()
    
    // urlQueryItems을 리턴하는 함수
    func makeUrlQueryItems(lat: Double, lon: Double) -> [URLQueryItem] {
        return [
            URLQueryItem(name: "lat", value: String(lat)), // 위도
            URLQueryItem(name: "lon", value: String(lon)), // 경도
            URLQueryItem(name: "appid", value: apiKey), // apiKey 추가
            URLQueryItem(name: "units", value: "metric") // 섭씨로 데이터 받기
        ]
    }
    
    func NOHUNmakeUrlQueryItems(lat: String, lon: String) -> [URLQueryItem] {
        return [
            URLQueryItem(name: "lat", value: lat), // 위도
            URLQueryItem(name: "lon", value: lon), // 경도
            URLQueryItem(name: "appid", value: apiKey), // apiKey 추가
            URLQueryItem(name: "units", value: "metric") // 섭씨로 데이터 받기
        ]
    }
    
    // Alamofire를 사용해서 서버 데이터를 불러오는 메서드
    func fetchDataByAlamofire<T: Decodable>(url: URL, completion: @escaping (Result<T, AFError>) -> Void) {
        AF.request(url).responseDecodable(of: T.self) { response in
            completion(response.result)
        }
    }
    
    // 서버에서 현재 날씨를 받아오는 메서드
    func fetchCurrentWeatherData(lat: Double, lon: Double) -> Single<(WeatherResponse, String)> {
        return Single.create { single in
            var urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
            urlComponents?.queryItems = self.makeUrlQueryItems(lat: lat, lon: lon)
            
            guard let url = urlComponents?.url else {
                print("잘못된 URL")
                single(.failure(AFError.invalidURL(url: "")))
                return Disposables.create()
            }
            
            self.fetchDataByAlamofire(url: url) { (result: Result<WeatherResponse, AFError>) in
                
                switch result {
                    
                    // 네트워크 통신 성공시
                case .success(let weatherResponse):
                    let imageUrl = "https://openweathermap.org/img/wn/\(weatherResponse.weather[0].icon)@2x.png"
                    single(.success((weatherResponse, imageUrl))) // 성공시 날씨 정보와 아이콘 이미지 url을 방출
                    
                    // 네트워크 통신 실패시
                case .failure(let error):
                    print("데이터 로드 실패: \(error)")
                    single(.failure(error)) // 실패시 에러 방출
                }
            }
            return Disposables.create() // Single 종료
        }
    }
    
    // 서버에서 현재 날씨를 받아오는 메서드
    func NOHUNfetchCurrentWeatherData(lat: String, lon: String) -> Single<(WeatherResponse, String)> {
        return Single.create { single in
            var urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
            urlComponents?.queryItems = self.NOHUNmakeUrlQueryItems(lat: lat, lon: lon)
            
            guard let url = urlComponents?.url else {
                print("잘못된 URL")
                single(.failure(AFError.invalidURL(url: "")))
                return Disposables.create()
            }
            
            self.fetchDataByAlamofire(url: url) { (result: Result<WeatherResponse, AFError>) in
                
                switch result {
                    
                    // 네트워크 통신 성공시
                case .success(let weatherResponse):
                    let imageUrl = "https://openweathermap.org/img/wn/\(weatherResponse.weather[0].icon)@2x.png"
                    single(.success((weatherResponse, imageUrl))) // 성공시 날씨 정보와 아이콘 이미지 url을 방출
                    
                    // 네트워크 통신 실패시
                case .failure(let error):
                    print("데이터 로드 실패: \(error)")
                    single(.failure(error)) // 실패시 에러 방출
                }
            }
            return Disposables.create() // Single 종료
        }
    }
    
    // 서버에서 5일 간 날씨 예보 데이터를 불러오는 메서드
    func fetchForeCastData(lat: Double, lon: Double) -> Single<WeatherForecast> {
        return Single.create { single in
            var urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/forecast")
            urlComponents?.queryItems = self.makeUrlQueryItems(lat: lat, lon: lon)
            
            guard let url = urlComponents?.url else {
                print("잘못된 URL")
                single(.failure(AFError.invalidURL(url: "")))
                return Disposables.create() // error를 방출하고 종료
            }
            
            self.fetchDataByAlamofire(url: url) { (result: Result<WeatherForecast, AFError>) in
                
                switch result {
                    
                    // 네트워크 통신 성공시
                case .success(let weatherForecast):
                    single(.success(weatherForecast)) // 결과를 방출
                    
                    // 네트워크 통신 실패시
                case .failure(let error):
                    print("데이터 로드 실패: \(error)")
                    single(.failure(error)) // 에러 방출
                }
            }
            return Disposables.create() // Single 종료
        }
    }
    
    // 서버에서 5일 간 날씨 예보 데이터를 불러오는 메서드
    func NOHUNfetchForeCastData(lat: String, lon: String) -> Single<WeatherForecast> {
        return Single.create { single in
            var urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/forecast")
            urlComponents?.queryItems = self.NOHUNmakeUrlQueryItems(lat: lat, lon: lon)
            
            guard let url = urlComponents?.url else {
                print("잘못된 URL")
                single(.failure(AFError.invalidURL(url: "")))
                return Disposables.create() // error를 방출하고 종료
            }
            
            self.fetchDataByAlamofire(url: url) { (result: Result<WeatherForecast, AFError>) in
                
                switch result {
                    
                    // 네트워크 통신 성공시
                case .success(let weatherForecast):
                    single(.success(weatherForecast)) // 결과를 방출
                    
                    // 네트워크 통신 실패시
                case .failure(let error):
                    print("데이터 로드 실패: \(error)")
                    single(.failure(error)) // 에러 방출
                }
            }
            return Disposables.create() // Single 종료
        }
    }
    
    
    // weatherForecast 와 icon image Data 배열 10개를 방출하는 함수
    func fetchForeCastAndTenImageData(lat: Double, lon: Double) -> Single<(WeatherForecast, [Data])> {
        return fetchForeCastData(lat: lat, lon: lon)
            .flatMap { weatherForecast in
                
                // 예보에서 아이콘 코드 최대 10개 추출
                let iconIds = weatherForecast.list.prefix(12).compactMap { $0.weather.first?.icon }
                
                // 각 아이콘 코드로부터 이미지 데이터 다운로드 요청 Single 배열
                let imageSingles = iconIds.map { iconIds in
                    return self.fetchIconImageData(iconIds: iconIds)
                }
                
                // 모든 이미지 데이터 다운로드 완료 후 결과 결합
                return Single.zip(imageSingles) { imageDatas in
                    return (weatherForecast, imageDatas)
                }
            }
    }
    
    // weatherForecast 와 icon image Data 배열 10개를 방출하는 함수
    func NOHUNfetchForeCastAndTenImageData(lat: String, lon: String) -> Single<(WeatherForecast, [Data])> {
        return NOHUNfetchForeCastData(lat: lat, lon: lon)
            .flatMap { weatherForecast in
                
                // 예보에서 아이콘 코드 최대 10개 추출
                let iconIds = weatherForecast.list.prefix(12).compactMap { $0.weather.first?.icon }
                
                // 각 아이콘 코드로부터 이미지 데이터 다운로드 요청 Single 배열
                let imageSingles = iconIds.map { iconIds in
                    return self.fetchIconImageData(iconIds: iconIds)
                }
                
                // 모든 이미지 데이터 다운로드 완료 후 결과 결합
                return Single.zip(imageSingles) { imageDatas in
                    return (weatherForecast, imageDatas)
                }
            }
    }
    
    // 날씨 아이콘을 불러오는 함수 - Data를 반환
    func fetchIconImageData(iconIds: String) -> Single<Data> {
        return Single.create { single in
            let imageUrl = "https://openweathermap.org/img/wn/\(iconIds)@2x.png"
            
            // alamofire을 이용해서 request 후 성공시 받은 response에서 data를 방출
            AF.request(imageUrl).responseData { response in
                switch response.result {
                case .success(let data):
                    single(.success(data)) // 성공시
                case .failure(let error):
                    single(.failure(error)) // 실패시
                }
            }
            
            return Disposables.create()
        }
    }
    
}
