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
        case searchButtonTap
        case changeCoordinate
        case searchAddressData(AddressData.Document.Address)
    }
    
    struct Output {
        let showSettingMenu = PublishRelay<Void>()
        let showSearchView = PublishRelay<Void>()
        
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
    
    init(locationViewModel: ViewModel ) {
        self.locationViewModel = locationViewModel
        applyDummyData() // 더미데이터 생성 메소드
        transform()
        setUpSideMenuNavigationVC()
        loadWeatherResponseData()
    }
    
    // 들어온 Input을 Output으로 변환하는 메서드
    private func transform() {
        self.input
            // 바인트에서 subscribe 바꾼거 트라블슈팅 넣어야됨
            //.bind(onNext: { [weak self] input in
        
            // 재진입 문제를 해결하기 위해 이벤트를 비동기적으로 전달하도록 처리
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] input in
                guard let self else { return }
                
                switch input {
                case .settingButtonTap:
                    output.showSettingMenu.accept(())
                case .searchButtonTap:
                    output.showSearchView.accept(())
                case .changeCoordinate:
                    self.locationViewModel.fetchRegionCode(longitude: self.longitude, latitude: self.latitude)
                    self.loadWeatherResponseData()
                    self.loadForecastListData()
                case .searchAddressData(let selectedAddress):
                    guard let x = selectedAddress.x,
                          let y = selectedAddress.y else { return }
                    self.locationViewModel.fetchRegionCode(longitude: x, latitude: y)
                    // 현재 날씨 데이터를 가져오는 로직
                    NetworkManager.shared.fetchCurrentWeatherData(lat: y, lon: x)
                        .subscribe(onSuccess:  { [weak self] (weather, imageURL) in
                            //print("불러온 날씨 데이터 : \n\(weather)")
                            self?.output.mainCellData.accept(weather)
                        }, onFailure: { error in
                            print(error)
                        }).disposed(by: self.disposeBag)
                    
                    // 뷰모델에 위도 경도 값 주입
                    self.latitude = "\(y)"
                    self.longitude = "\(x)"
                    
                    // 인풋 안에 인풋
                    // RxSwift 공식 가이드는, 재진입 문제를 피하려면 Observable이 이벤트를 비동기적으로 전달하도록 처리하라고 권장
                    self.input.accept(.changeCoordinate)
                }
            }).disposed(by: disposeBag)
    }
    
    // WeatherResponse 모델의 정보를 받아오는 메서드 loadForecastListData
    private func loadForecastListData() {
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

            }, onFailure: { error in
                print("loadForecastListData forecast 로딩 실패: \(error)")
            })
            .disposed(by: disposeBag)
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
    
    private func loadWeatherResponseData() {
        NetworkManager.shared.fetchCurrentWeatherData(lat: latitude, lon: longitude)
            .subscribe { [weak self] (weather, imageURL) in
                guard let self else { return }
                self.output.mainCellData.accept(weather)
            } onFailure: { error in
                print(error)
            }.disposed(by: disposeBag)
    }
    
//    private func NOHUNloadWeatherResponseData() {
//        NetworkManager.shared.fetchCurrentWeatherData(lat: latitude, lon: longitude)
//            .subscribe { [weak self] (weather, imageURL) in
//                guard let self else { return }
//                self.output.mainCellData.accept(weather)
//            } onFailure: { error in
//                print(error)
//            }.disposed(by: disposeBag)
//    }
    
    // 세팅 버튼을 클릭하면 세팅 뷰를 띄워주는 메서드
    func showSettingMenu(on vc: UIViewController) {
        guard let sideMenu = SideMenuManager.default.leftMenuNavigationController else { return }
        vc.present(sideMenu, animated: true)
    }
    
    // 세팅 뷰 사이드메뉴 라이브러리 설정
    private func setUpSideMenuNavigationVC() {
        let menuNavVC = SideMenuNavigationController(rootViewController: SettingsViewController())
        
        menuNavVC.menuWidth = UIScreen.main.bounds.width * 0.7
        menuNavVC.presentationStyle = .menuSlideIn
        SideMenuManager.default.leftMenuNavigationController = menuNavVC
//           SideMenuManager.default.leftMenuNavigationController?.setNavigationBarHidden(true, animated: true)
    }
}

extension MainViewModel {

    /// 더미 데이터 생성 메소드
    func applyDummyData() {
        // 1. 현재 날씨 더미
        let dummyWeather = WeatherResponse(
            coord: Coord(lon: 127.0, lat: 37.5),
            weather: [Weather(id: 800, main: "Clear", description: "clear sky", icon: "01d")],
            base: "stations",
            main: Main(
                temp: 24.0, feelsLike: 24.5, tempMin: 22.0, tempMax: 26.0,
                pressure: 1012, humidity: 50, seaLevel: 1012, grndLevel: 1005
            ),
            visibility: 10000,
            wind: Wind(speed: 3.0, deg: 180, gust: nil),
            clouds: Clouds(all: 0),
            dt: Int(Date().timeIntervalSince1970),
            sys: Sys(country: "KR", sunrise: 1716600000, sunset: 1716648000),
            timezone: 32400,
            id: 1835847,
            name: "서울",
            cod: 200
        )
        output.mainCellData.accept(dummyWeather)

        // 2. ForecastList 더미 6개 (3시간 간격 예보)
        let dummyForecastList: [ForecastList] = (0..<10).map { createDummyForecastList(index: $0) }

        let dummyIcon = UIImage(systemName: "sun.max.fill") ?? UIImage()
        let iconList = Array(repeating: dummyIcon, count: dummyForecastList.count)

        let forecastData = tenDayForecastData(
            forecastList: dummyForecastList,
            weatherIcons: iconList
        )
        output.NOHUNforecastListCellData.accept(forecastData)

        // 3. CustomForecastList 더미 5일치
        let dummyCustomForecast: [CustomForecastData] = (1...5).map { day in
            let custom = CustomForecastList(
                day: String(format: "%02d", day),
                tempMin: 18.0 + Double(day),
                tempMax: 28.0 + Double(day),
                pop: Double(day) * 0.1,
                icon: "01d"
            )
            return CustomForecastData(
                forecastList: custom,
                weatherIcons: dummyIcon
            )
        }

        output.customForecastData.accept(dummyCustomForecast)
    }

    private func createDummyForecastList(index i: Int) -> ForecastList {
        let baseDate = Date().addingTimeInterval(Double(i * 3 * 3600))
        let main = MainClass(
            temp: 23 + Double(i),
            feelsLike: 23 + Double(i),
            tempMin: 20,
            tempMax: 28,
            pressure: 1012,
            seaLevel: 1012,
            grndLevel: 1005,
            humidity: 60,
            tempKf: 0
        )
        let weather = ForecastWeather(id: 800, main: .clear, description: "clear", icon: "01d")
        let clouds = ForecastClouds(all: 0)
        let wind = ForecastWind(speed: 3.5, deg: 200, gust: 4.0)
        let sys = ForecastSys(pod: .d)

        return ForecastList(
            dt: Int(baseDate.timeIntervalSince1970),
            main: main,
            weather: [weather],
            clouds: clouds,
            wind: wind,
            visibility: 10000,
            pop: 0.1,
            rain: nil,
            sys: sys,
            dtTxt: dateToString(baseDate)
        )
    }

    private func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
}
