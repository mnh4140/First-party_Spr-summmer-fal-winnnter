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
        let tenForecastCellData = BehaviorRelay<TenForecastData?>(value: nil)
        let allForecastCellData = BehaviorRelay<[AllForecastData]?>(value: nil)
    }
    
    struct TenForecastData {
        let forecastList: [ForecastList]
        let weatherIcons: [UIImage]
    }
    
    struct AllForecastData {
        let forecastList: CustomForecastList
        let weatherIcons: UIImage
    }
    
    private var customForecastDatas = [AllForecastData]()
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
                
                self.transformForecastListData(data: weather.list)
                
                image = [UIImage](image.prefix(12))
                var list = [ForecastList](weather.list.prefix(12))
                
                list.removeFirst(2)
                image.removeFirst(2)
                
                let tenResult = TenForecastData(forecastList: list, weatherIcons: image)
                self.output.tenForecastCellData.accept(tenResult)
            } onFailure: { error in
                print(error)
            }.disposed(by: disposeBag)

    }
    
    private func transformForecastListData(data: [ForecastList]) {
        let firstHour = String(data[0].dtTxt.components(separatedBy: " ")[1].prefix(2))
        var list = data
        var box = [ForecastList]()
        var result = [[ForecastList]]()
        
        switch firstHour {
        case "18":
            list.removeFirst()
            fallthrough
        case "21":
            list.removeFirst()
        default:
            break
        }
        
        switch String(list[0].dtTxt.components(separatedBy: " ")[1].prefix(2)) {
        case "00":
            box.append(list.removeFirst())
            fallthrough
        case "03":
            box.append(list.removeFirst())
            fallthrough
        case "06":
            box.append(list.removeFirst())
            fallthrough
        case "09":
            box.append(list.removeFirst())
            fallthrough
        case "12":
            box.append(list.removeFirst())
            fallthrough
        case "15":
            box.append(list.removeFirst())
            fallthrough
        case "18":
            box.append(list.removeFirst())
            fallthrough
        case "21":
            box.append(list.removeFirst())
        default:
            break
        }
        
        result.append(box)
        box.removeAll()
        
        while list.count > 1 {
            box.append(list.removeFirst())
            if box.count == 8 {
                result.append(box)
                box.removeAll()
            }
        }
        
        if box.count > 0 {
            result.append(box)
        }
        
        var customForecastList = [CustomForecastList]()
        
        result.forEach {
            let day = String($0[0].dtTxt.split(separator: " ")[0].suffix(2))
            let tempMin = $0.sorted(by: { $0.main.tempMin < $1.main.tempMin })[0].main.tempMin
            let tempMax = $0.sorted(by: { $0.main.tempMax > $1.main.tempMax })[0].main.tempMin
            let pop = $0.sorted(by: { $0.pop > $1.pop })[0].pop
            let icon = $0.sorted(by: { $0.pop > $1.pop })[0].weather[0].icon
            
            customForecastList.append(CustomForecastList(day: day,
                                                     tempMin: tempMin,
                                                     tempMax: tempMax,
                                                     pop: pop,
                                                     icon: icon))
        }
        
        customForecastList.forEach {
            self.fetchCustomForecastListIcon(data: $0)
        }
        
    }
    
    private func fetchCustomForecastListIcon(data: CustomForecastList) {
        let customForecast = Single<CustomForecastList>.just(data)
        let icon = NetworkManager.shared.fetchIconImageData(iconIds: data.icon)
        
        Single.zip(customForecast, icon)
            .subscribe { custom, data in
                guard let image = UIImage(data: data) else { return }
                self.customForecastDatas.append(AllForecastData(forecastList: custom, weatherIcons: image))
                if self.customForecastDatas.count == 5 {
                    self.output.allForecastCellData.accept(self.customForecastDatas)
                }
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
