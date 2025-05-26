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

        let tenDayForecastCellData = BehaviorRelay<tenDayForecastData?>(value: nil)
        let customForecastData = BehaviorRelay<[CustomForecastData]?>(value: nil)

        let forecastListCellData = BehaviorRelay<tenDayForecastData?>(value: nil)
        let NOHUNforecastListCellData = BehaviorRelay<tenDayForecastData?>(value: nil)
    }
    
    struct tenDayForecastData {
        let forecastList: [ForecastList]
        let weatherIcons: [UIImage]
    }
    
    struct CustomForecastData {
        let forecastList: CustomForecastList
        let weatherIcons: UIImage
    }
    
    private var customForecastDatas = [CustomForecastData]()
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
//        loadWeatherResponseData()
        //loadForecastListData()
    }
    
    // 들어온 Input을 Output으로 변환하는 메서드
    private func transform() {
        //print("\t📋 [메인 모델] MainViewModel transform")
        self.input
            //.bind(onNext: { [weak self] input in
            .subscribe(onNext: { [weak self] input in
                guard let self else { return }
                
                switch input {
                case .settingButtonTap:
//                    print("\t\t📋 [메인 모델] MainViewModel transform settingButtonTap:")
                    output.showSettingMenu.accept(())
                case .changeCoordinate:
//                    print("\t\t📋 [메인 모델] MainViewModel transform changeCoordinate:")
//                    print("\t\t📋 [메인 모델] MainViewModel transform 좌표 값 받아옴 : \(self.latitude), \(self.longitude)")
                    self.locationViewModel.fetchRegionCode(longitude: self.longitude, latitude: self.latitude)
//                    self.NOHUNloadWeatherResponseData()
//                    print("\t\t\t📋 [메인 모델] NOHUNloadWeatherResponseData 실행")
                    self.NOHUNloadForecastListData()
//                    print("\t\t\t📋 [메인 모델] NOHUNloadForecastListData 실행")
                }
            }).disposed(by: disposeBag)
    }
    
    // WeatherForecast 모델의 정보를 받아와 필요한 곳으로 보내는 메서드
    private func loadForecastListData() {
        NetworkManager.shared.fetchForeCastAndTenImageData(lat: latitude, lon: longitude)
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
                
                let tenResult = tenDayForecastData(forecastList: list, weatherIcons: image)
                self.output.tenDayForecastCellData.accept(tenResult)
            } onFailure: { error in
                print(error)
            }.disposed(by: disposeBag)

    }
    
    // ForecastList의 데이터를 CustomForecastList로 변환하는 메서드
    private func transformForecastListData(data: [ForecastList]) {
        var list = data                 // removeFirst 메서드를 사용하기 위해 변수 생성
        var box = [ForecastList]()      // result에 들어갈 데이터를 하루 단위로 담았다가 배열로 보내주기 위해 생성
        var result = [[ForecastList]]() // 데이터를 하루 단위의 배열로 가지게 될 변수
        
        // 첫 데이터의 시간 체크
        var firstHour = String(list[0].dtTxt.components(separatedBy: " ")[1].prefix(2))
        
        // ForecastList는 6시간 전의 데이터부터 불러옴
        // 그래서 만약 이전 시간이 어제일 경우 데이터 삭제
        switch firstHour {
        case "18":
            list.removeFirst()
            fallthrough
        case "21":
            list.removeFirst()
        default:
            break
        }
        
        // 첫 데이터 시간 체크 갱신
        firstHour = String(list[0].dtTxt.components(separatedBy: " ")[1].prefix(2))
        
        // 첫 날(오늘) 데이터를 box에 담음
        switch firstHour {
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
        
        // 첫 날의 데이터를 배열로 result에 담고
        // box의 데이터 삭제
        result.append(box)
        box.removeAll()
        
        // 위 작업을 하루 단위로 반복
        while list.count > 1 {
            box.append(list.removeFirst())
            if box.count == 8 {
                result.append(box)
                box.removeAll()
            }
        }
        
        // 반복문을 빠져나와 남은 데이터가 있을 시 result에 담음
        if box.count > 0 {
            result.append(box)
        }
        
        // customForecastList로 변환해 담을 변수
        var customForecastList = [CustomForecastList]()
        
        // result -> customForecastList 변환 작업
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
        
        // 데이터를 담을 변수 초기화
        self.customForecastDatas = []
        
        // Icon을 불러오는 메서드 실행
        customForecastList.forEach {
            self.fetchCustomForecastListIcon(data: $0)
        }
        
    }
    
    // CustomForecastList의 데이터 중 Icon을 받아오는 메서드
    private func fetchCustomForecastListIcon(data: CustomForecastList) {
        
        // zip을 사용하기 위해 Single로 생성
        let customForecast = Single<CustomForecastList>.just(data)
        let icon = NetworkManager.shared.fetchIconImageData(iconIds: data.icon)
        
        Single.zip(customForecast, icon)
            .subscribe { customForecast, imageData in
                guard let image = UIImage(data: imageData) else { return }
                
                // 데이터를 변수에 추가
                self.customForecastDatas.append(CustomForecastData(forecastList: customForecast, weatherIcons: image))
                
                // 5일의 데이터가 쌓이면 accept
                if self.customForecastDatas.count == 5 {
                    self.output.customForecastData.accept(self.customForecastDatas)
                }
            } onFailure: { error in
                print(error)
            }.disposed(by: disposeBag)

    }
    
    // WeatherResponse 모델의 정보를 받아오는 메서드
    private func NOHUNloadForecastListData() {
        print("\t📋 [메인 모델] MainViewModel NOHUNloadForecastListData")
        NetworkManager.shared.fetchForeCastAndTenImageData(lat: latitude, lon: longitude)
            .subscribe(onSuccess: { [weak self] weather, data in
                guard let self else { return }
//                print("\t\t📋 [메인 모델] MainViewModel NOHUNloadForecastListData fetch 성공!")

                var image = [UIImage]()
                data.forEach {
                    if let changedData = UIImage(data: $0) {
                        image.append(changedData)
                    }
                }
                
                self.transformForecastListData(data: weather.list)

                var list = [ForecastList](weather.list.prefix(12))
                image = [UIImage](image.prefix(12))

                if list.count >= 2 { list.removeFirst(2) }
                if image.count >= 2 { image.removeFirst(2) }

                let result = tenDayForecastData(forecastList: list, weatherIcons: image)
                self.output.NOHUNforecastListCellData.accept(result)
                
//                print("\t\t\t📋 [메인 모델] MainViewModel NOHUNloadForecastListData NOHUNforecastListCellData.accept 성공!")
//                print("\n 받아온 데이터 \n/\(result.forecastList)")

            }, onFailure: { error in
//                print("\t\t\t📋 [메인 모델] MainViewModel NOHUNloadForecastListData forecast 로딩 실패: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
//    private func loadWeatherResponseData() {
//        //print("\t📋 [메인 모델] MainViewModel loadWeatherResponseData 실행")
//        NetworkManager.shared.fetchCurrentWeatherData(lat: latitude, lon: longitude)
//            .subscribe { [weak self] (weather, imageURL) in
//                guard let self else { return }
//                self.output.mainCellData.accept(weather)
//            } onFailure: { error in
//                print(error)
//            }.disposed(by: disposeBag)
//    }
//    
//
//    // 세팅 버튼을 클릭하면 세팅 뷰를 띄워주는 메서드
//    private func NOHUNloadWeatherResponseData() {
//        //print("\t📋 [메인 모델] MainViewModel loadWeatherResponseData 실행")
//        NetworkManager.shared.fetchCurrentWeatherData(lat: latitude, lon: longitude)
//            .subscribe { [weak self] (weather, imageURL) in
//                guard let self else { return }
//                self.output.mainCellData.accept(weather)
//            } onFailure: { error in
//                print(error)
//            }.disposed(by: disposeBag)
//    }

    func showSettingMenu(on vc: UIViewController) {
        //print("\t📋 [메인 모델] howSettingMenu 실행")
        guard let sideMenu = SideMenuManager.default.leftMenuNavigationController else { return }
        vc.present(sideMenu, animated: true)
    }
    
    // 세팅 뷰 사이드메뉴 라이브러리 설정
    private func setUpSideMenuNavigationVC() {
        //print("\t📋 [메인 모델] MainViewModel setUpSideMenuNavigationVC 실행")
        let menuNavVC = SideMenuNavigationController(rootViewController: SettingsViewController())
        
        menuNavVC.menuWidth = UIScreen.main.bounds.width * 0.7
        menuNavVC.presentationStyle = .menuSlideIn
        SideMenuManager.default.leftMenuNavigationController = menuNavVC
//           SideMenuManager.default.leftMenuNavigationController?.setNavigationBarHidden(true, animated: true)
    }
}
