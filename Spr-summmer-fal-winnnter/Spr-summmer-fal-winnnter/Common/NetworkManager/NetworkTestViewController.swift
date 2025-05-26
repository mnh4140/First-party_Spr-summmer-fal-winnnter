////
////  NetworkTestViewController.swift
////  Spr-summmer-fal-winnnter
////
////  Created by 허성필 on 5/22/25.
////
//
//import UIKit
//import RxSwift
//import SnapKit
//import Alamofire
//
//class NetworkTestViewController: UIViewController {
//
//    var disposeBag = DisposeBag()
//    let network = NetworkManager.shared
//    
//    private let currentWeatherLabel: UILabel = {
//        let label = UILabel()
//        label.text = ""
//        label.numberOfLines = 0
//        label.textAlignment = .center
//        return label
//    }()
//    
//    private let imageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        return imageView
//    }()
//    
//    private let forecastWeatherLabel: UILabel = {
//        let label = UILabel()
//        label.text = ""
//        label.numberOfLines = 0
//        label.textAlignment = .center
//        return label
//    }()
//    
//    private let forecastWeatherLabel2: UILabel = {
//        let label = UILabel()
//        label.text = ""
//        label.numberOfLines = 0
//        label.textAlignment = .center
//        return label
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        view.backgroundColor = .white
//        
//        // 현재 날씨 네트워크 통신 테스트
//        fetchCurrentWeatherResponse()
//        
//        // 날씨 예보 네트워크 통신 테스트
//        fetchForeCastResponse()
//
//        // 화면에 표시 테스트
//        configureUI()
//    }
//    
//    func configureUI() {
//        [currentWeatherLabel, imageView, forecastWeatherLabel, forecastWeatherLabel2].forEach {
//            view.addSubview($0)
//        }
//
//        currentWeatherLabel.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide).offset(100)
//            make.centerX.equalToSuperview()
//        }
//
//        imageView.snp.makeConstraints { make in
//            make.top.equalTo(currentWeatherLabel.snp.bottom).offset(20)
//            make.centerX.equalToSuperview()
//            make.width.height.equalTo(150) // 이미지 크기 설정
//        }
//
//        forecastWeatherLabel.snp.makeConstraints { make in
//            make.top.equalTo(imageView.snp.bottom).offset(20)
//            make.centerX.equalToSuperview()
//        }
//        
//        forecastWeatherLabel2.snp.makeConstraints { make in
//            make.top.equalTo(forecastWeatherLabel.snp.bottom).offset(20)
//            make.centerX.equalToSuperview()
//        }
//    }
//    
//    func fetchCurrentWeatherResponse() {
//        network.NOHUNfetchCurrentWeatherData(lat: latitude, lon: longitude)
//            .subscribe { (weather, imageUrl) in
//                print("날씨 정보 : \(weather)")
//                self.currentWeatherLabel.text = "현재 기온 : \(Int(weather.main.temp))°C"
//                print("날씨 아이콘 주소 : \(imageUrl)")
//                AF.request(imageUrl).responseData { response in
//                    if let data = response.data, let image = UIImage(data: data) {
//                        DispatchQueue.main.async {
//                            self.imageView.image = image
//                        }
//                    }
//                }
//            } onFailure: { error in
//                print("에러 발생 : \(error)")
//            }.disposed(by: disposeBag)
//    }
//    
//    
//    func fetchForeCastResponse() {
//        network.NOHUNfetchForeCastData(lat: latitude, lon: longitude)
//            .subscribe { weather in
//                print("5일간 날씨 예보 : \(Int(weather.list[0].main.temp))°C")
//                self.forecastWeatherLabel.text = "5일간 날씨 예보 기온 : \(Int(weather.list[0].main.temp))°C"
//                self.forecastWeatherLabel2.text = "3시간 후 기온 : \(Int(weather.list[1].main.temp))°C"
//            } onFailure: { error in
//                print("에러 발생 : \(error)")
//            }.disposed(by: disposeBag)
//
//    }
//}
