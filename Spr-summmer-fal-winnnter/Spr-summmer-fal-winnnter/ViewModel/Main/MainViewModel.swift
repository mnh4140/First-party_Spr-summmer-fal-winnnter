//
//  MainViewModel.swift
//  Spr-summmer-fal-winnnter
//
//  Created by NH on 5/21/25.
//

import UIKit
import Foundation
import RxSwift
import RxRelay
import SideMenu
import Alamofire

class MainViewModel {
    
    enum Input {
        case settingButtonTap
        case changeCoordinate
    }
    
    struct Output {
        let showSettingMenu = PublishRelay<Void>()
        let mainCellData = BehaviorRelay<WeatherResponse?>(value: nil)
        let forecastListCellData = BehaviorRelay<ForecastData?>(value: nil)
        let NOHUNforecastListCellData = BehaviorRelay<ForecastData?>(value: nil)
    }
    
    struct ForecastData {
        let forecastList: [ForecastList]
        let weatherIcons: [UIImage]
    }
    
    private let disposeBag = DisposeBag()
    
    let input = PublishRelay<Input>()
    let output = Output()
    
    var latitude: String = ""
    var longitude: String = ""
    
    let locationViewModel: ViewModel
    
    //var locationViewModel = ViewModel()
    init(locationViewModel: ViewModel ) {
        self.locationViewModel = locationViewModel
        //print("📋 [메인 모델] MainViewModel 초기화")
        transform()
        setUpSideMenuNavigationVC()
        loadWeatherResponseData()
        //loadForecastListData()
    }
    
    private func transform() {
        //print("\t📋 [메인 모델] MainViewModel transform")
        self.input
            //.bind(onNext: { [weak self] input in
            .subscribe(onNext: { [weak self] input in
                guard let self else { return }
                
                switch input {
                case .settingButtonTap:
                    //print("\t\t📋 [메인 모델] MainViewModel transform settingButtonTap:")
                    output.showSettingMenu.accept(())
                case .changeCoordinate:
                    //print("\t\t📋 [메인 모델] MainViewModel transform changeCoordinate:")
                    //print("\t\t📋 [메인 모델] MainViewModel transform 좌표 값 받아옴 : \(self.latitude), \(self.longitude)")
                    self.locationViewModel.fetchRegionCode(longitude: self.longitude, latitude: self.latitude)
                    self.NOHUNloadWeatherResponseData()
                    //print("\t\t\t📋 [메인 모델] NOHUNloadWeatherResponseData 실행")
                    self.NOHUNloadForecastListData()
                    //print("\t\t\t📋 [메인 모델] NOHUNloadForecastListData 실행")
                }
            }).disposed(by: disposeBag)
    }
    
    private func loadForecastListData() {
        NetworkManager.shared.fetchForeCastAndTenImageData(lat: 37.5, lon: 126.9)
            .subscribe { weather, data in
                var image = [UIImage]()
                data.forEach {
                    guard let changedData = UIImage(data: $0) else { return }
                    image.append(changedData)
                }
                
                var list = [ForecastList](weather.list.prefix(12))
                list.removeFirst(2)
                image.removeFirst(2)
                
                let result = ForecastData(forecastList: list, weatherIcons: image)
                self.output.forecastListCellData.accept(result)
            } onFailure: { error in
                print(error)
            }.disposed(by: disposeBag)

    }
    
    private func NOHUNloadForecastListData() {
        //print("\t📋 [메인 모델] MainViewModel NOHUNloadForecastListData")
        NetworkManager.shared.NOHUNfetchForeCastAndTenImageData(lat: latitude, lon: longitude)
            .subscribe(onSuccess: { [weak self] weather, data in
                guard let self else { return }
                //print("\t\t📋 [메인 모델] MainViewModel NOHUNloadForecastListData fetch 성공!")

                var image = [UIImage]()
                data.forEach {
                    if let changedData = UIImage(data: $0) {
                        image.append(changedData)
                    }
                }

                var list = [ForecastList](weather.list.prefix(12))

                if list.count >= 2 { list.removeFirst(2) }
                if image.count >= 2 { image.removeFirst(2) }

                let result = ForecastData(forecastList: list, weatherIcons: image)
                self.output.NOHUNforecastListCellData.accept(result)
                
                //print("\t\t\t📋 [메인 모델] MainViewModel NOHUNloadForecastListData NOHUNforecastListCellData.accept 성공!")
                //print("\n 받아온 데이터 \n/\(result.forecastList)")

            }, onFailure: { error in
                //print("\t\t\t📋 [메인 모델] MainViewModel NOHUNloadForecastListData forecast 로딩 실패: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    private func loadWeatherResponseData() {
        //print("\t📋 [메인 모델] MainViewModel loadWeatherResponseData 실행")
        NetworkManager.shared.fetchCurrentWeatherData(lat: 37.5, lon: 126.9)
            .subscribe { [weak self] (weather, imageURL) in
                guard let self else { return }
                self.output.mainCellData.accept(weather)
            } onFailure: { error in
                print(error)
            }.disposed(by: disposeBag)
    }
    
    private func NOHUNloadWeatherResponseData() {
        //print("\t📋 [메인 모델] MainViewModel loadWeatherResponseData 실행")
        NetworkManager.shared.NOHUNfetchCurrentWeatherData(lat: latitude, lon: longitude)
            .subscribe { [weak self] (weather, imageURL) in
                guard let self else { return }
                self.output.mainCellData.accept(weather)
            } onFailure: { error in
                print(error)
            }.disposed(by: disposeBag)
    }
    
    func showSettingMenu(on vc: UIViewController) {
        //print("\t📋 [메인 모델] howSettingMenu 실행")
        guard let sideMenu = SideMenuManager.default.leftMenuNavigationController else { return }
        vc.present(sideMenu, animated: true)
    }
    
    private func setUpSideMenuNavigationVC() {
        //print("\t📋 [메인 모델] MainViewModel setUpSideMenuNavigationVC 실행")
        let menuNavVC = SideMenuNavigationController(rootViewController: SettingsViewController())
        
        menuNavVC.menuWidth = UIScreen.main.bounds.width * 0.7
        menuNavVC.presentationStyle = .menuSlideIn
        SideMenuManager.default.leftMenuNavigationController = menuNavVC
//           SideMenuManager.default.leftMenuNavigationController?.setNavigationBarHidden(true, animated: true)
    }
}
