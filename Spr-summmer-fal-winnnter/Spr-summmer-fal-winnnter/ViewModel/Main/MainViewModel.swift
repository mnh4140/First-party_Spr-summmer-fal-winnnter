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
    }
    
    struct Output {
        let showSettingMenu = PublishRelay<Void>()
        let mainCellData = BehaviorRelay<WeatherResponse?>(value: nil)
        let forecastListCellData = BehaviorRelay<ForecastData?>(value: nil)
    }
    
    struct ForecastData {
        let forecastList: [ForecastList]
        let weatherIcons: [UIImage]
    }
    
    private let disposeBag = DisposeBag()
    
    let input = PublishRelay<Input>()
    let output = Output()
    
    init() {
        transform()
        setUpSideMenuNavigationVC()
        loadWeatherResponseData()
        loadForecastListData()
    }
    
    private func transform() {
        self.input.bind(onNext: { [weak self] input in
            guard let self else { return }
            
            switch input {
            case .settingButtonTap:
                output.showSettingMenu.accept(())
            }
        }).disposed(by: disposeBag)
    }
    
    private func loadForecastListData() {
        NetworkManager.shared.fetchForeCastData(lat: 37.5, lon: 126.9)
            .flatMap { forecast in
                let tenItems = [ForecastList](forecast.list.prefix(10))
                
                let imageSingle = tenItems.map { list in
                    NetworkManager.shared.loadIconImage(icon: list.weather[0].icon)
                }
                
                return Single.zip(imageSingle)
                    .map { image in
                        ForecastData(forecastList: tenItems, weatherIcons: image)
                    }
            }
            .subscribe { data in
                self.output.forecastListCellData.accept(data)
                
            } onFailure: { error in
                print(error)
            }.disposed(by: disposeBag)
        
    }
    
    private func loadWeatherResponseData() {
        NetworkManager.shared.fetchCurrentWeatherData(lat: 37.5, lon: 126.9)
            .subscribe { [weak self] (weather, imageURL) in
                guard let self else { return }
                self.output.mainCellData.accept(weather)
            } onFailure: { error in
                print(error)
            }.disposed(by: disposeBag)
    }
    
    func showSettingMenu(on vc: UIViewController) {
        guard let sideMenu = SideMenuManager.default.leftMenuNavigationController else { return }
        vc.present(sideMenu, animated: true)
    }
    
    private func setUpSideMenuNavigationVC() {
        let menuNavVC = SideMenuNavigationController(rootViewController: SettingsViewController())
        
        menuNavVC.menuWidth = UIScreen.main.bounds.width * 0.7
        menuNavVC.presentationStyle = .menuSlideIn
        SideMenuManager.default.leftMenuNavigationController = menuNavVC
//           SideMenuManager.default.leftMenuNavigationController?.setNavigationBarHidden(true, animated: true)
    }
}
