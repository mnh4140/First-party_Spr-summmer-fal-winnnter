//
//  MainViewController.swift
//  Spr-summmer-fal-winnnter
//
//  Created by NH on 5/21/25.
//

import Foundation
import RxSwift
import UIKit
import RxCocoa
import SnapKit

// MARK: - MainViewController
class MainViewController: UIViewController {
    
    // Property
    private let disposeBag = DisposeBag()
    private let viewModel = MainViewModel()
    let locationViewModel = ViewModel()
    
    // MARK: - UIProperty
    private lazy var weatherCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewConfigure())
        collectionView.backgroundColor = .clear
        
        collectionView.register(MainCell.self,
                                forCellWithReuseIdentifier: MainCell.identifier)
        collectionView.register(ClothesCell.self,
                                forCellWithReuseIdentifier: ClothesCell.identifier)
        collectionView.register(ForecastListCell.self,
                                forCellWithReuseIdentifier: ForecastListCell.identifier)
        collectionView.register(TenDayForecastCell.self,
                                forCellWithReuseIdentifier: TenDayForecastCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        return collectionView
    }()
}

// MARK: - Lifecycle
extension MainViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        inputBind()
        bindLocationManager()
        LocationManager.shared.requestLocation()
        cellSelect()
    }
}

// MARK: - Method
extension MainViewController {
    
    private func bind() {
        viewModel.output.showSettingMenu
            .subscribe { [weak self] _ in
                guard let self else { return }
                self.viewModel.showSettingMenu(on: self)
            }.disposed(by: disposeBag)
        
        viewModel.output.mainCellData
            .subscribe { [weak self] _ in
                self?.weatherCollectionView.reloadData()
            }.disposed(by: disposeBag)
        
        viewModel.output.forecastListCellData
            .subscribe { [weak self] weather in
                guard let self else { return }
                self.weatherCollectionView.reloadData()
            }.disposed(by: disposeBag)
    }
    
    private func inputBind() {
        self.navigationItem.leftBarButtonItem?.rx.tap.subscribe { [weak self] _ in
            guard let self else { return }
            self.viewModel.input.accept(.settingButtonTap)
        }.disposed(by: disposeBag)
    }
    
    /// 메인셀 선택 시, 검색 화면으로 넘어가는 기능
    func cellSelect() {
        weatherCollectionView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                if MainViewController.Section(rawValue: indexPath.section) == .main {
                    print("메인 셀이 눌렸습니다.")
                    let searchVC = SearchViewController()
                        searchVC.viewModel = self.locationViewModel // 같은 인스턴스 전달
                    searchVC.mainViewModel = self.viewModel
                    self.navigationController?.pushViewController(searchVC, animated: true)
                }
            }).disposed(by: disposeBag)
    }
    
    /// - 위치 관리자에게 사용자의 위도 경도 데이터 받아오는 기능
    func bindLocationManager() {
        // LocationManager의 coordinateSubject 구독
        // 현재 위치 정보가 변경되면 onNext 콜백이 실행
        // 위도 경도를 받아오고
        // fetchRegionCode 를 호출하여, 위도 경도를 주소로 변경된 값을 가져옴
        LocationManager.shared.coordinateSubject
            .subscribe(onNext: { [weak self] coordinate in
                let longitude = "\(coordinate.longitude)"
                let latitude = "\(coordinate.latitude)"
                self?.locationViewModel.fetchRegionCode(longitude: longitude, latitude: latitude)
                print("위도 경도는 longitude : \(longitude), latitude : \(latitude)")
                NetworkManager.shared.NOHUNfetchCurrentWeatherData(lat: latitude, lon: longitude)
                    .subscribe(onSuccess:  { (weather, imageURL) in
                        print("불러온 날씨 데이터 : \(weather)")
                        self?.viewModel.output.mainCellData.accept(weather)
                    }, onFailure: { error in
                        print(error)
                    }).disposed(by: self?.disposeBag ?? DisposeBag())
            }).disposed(by: disposeBag)
    }
    
    private func setupUI() {
        let menuButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal"),
            style: .plain,
            target: nil,
            action: nil)
        menuButton.tintColor = .black
        
        self.navigationItem.leftBarButtonItem = menuButton
        
        view.backgroundColor = UIColor(red: 154/255, green: 203/255, blue: 208/255, alpha: 1.0)
        view.addSubview(weatherCollectionView)
        
        weatherCollectionView.snp.makeConstraints {
            $0.height.width.equalTo(view.safeAreaLayoutGuide).inset(32)
            $0.center.equalToSuperview()
        }
    }
    
}

// MARK: - CollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    
}

// MARK: - CollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .main: return 1
        case .clothes: return 1
        case .forecastList: return self.viewModel.output.forecastListCellData.value?.forecastList.count ?? 0
        case .tenDayForecast: return 10
        case .none: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch Section(rawValue: indexPath.section) {
        case .main:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCell.identifier, for: indexPath) as? MainCell else { return .init() }
            
            guard let weather = viewModel.output.mainCellData.value else { return cell }
                
            cell.setText(weather: weather)
            
            // 여기서 주소도 전달
            cell.bindAddress(with: locationViewModel)
            
            return cell
        case .clothes:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ClothesCell.identifier, for: indexPath) as? ClothesCell else { return .init() }
            
            cell.test()
            
            return cell
        case .forecastList:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ForecastListCell.identifier, for: indexPath) as? ForecastListCell else { return .init() }
            
            guard let data = self.viewModel.output.forecastListCellData.value else { return cell }
            
            if indexPath.row == 0 {
                cell.setFirstCell(data: data.forecastList[indexPath.row],
                                  icon: data.weatherIcons[indexPath.row])
            } else {
                cell.setCell(data: data.forecastList[indexPath.row],
                             icon: data.weatherIcons[indexPath.row])
            }
            
            return cell
        case .tenDayForecast:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TenDayForecastCell.identifier, for: indexPath) as? TenDayForecastCell else { return .init() }
            
            if indexPath.row == 0 {
                // 첫 번째 셀
                // cell.setCurrentTemp(data: <#T##ForecastList#>)
                cell.testFirstCell()
            } else if indexPath.row == 9 {
                // 마지막 셀
                cell.deleteSeparator()
            }
            
            cell.test()
            
            return cell
        case .none:
            return .init()
        }
    }
    
    private func collectionViewConfigure() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            guard let section = Section(rawValue: sectionIndex) else { return nil }
            
            switch section {
            case .main: return self.mainSectionConfigure()
            case .clothes: return self.mainSectionConfigure()
            case .forecastList: return self.forecastListSectionConfigure()
            case .tenDayForecast: return self.tenDayForecastSectionConfigure()
            }
            
        }
        
        layout.register(CellBackground.self, forDecorationViewOfKind: "section-background-element-kind")
        
        return layout
    }
    
    private func tenDayForecastSectionConfigure() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1),
                              heightDimension: .fractionalHeight(1)
        ))
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1),
                              heightDimension: .fractionalWidth(0.3)),
            subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "section-background-element-kind")
        
        section.decorationItems = [decorationItem]
        
        return section
    }
    
    private func forecastListSectionConfigure() -> NSCollectionLayoutSection {
        let item0 = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1/5),
                              heightDimension: .fractionalHeight(1/2)
        ))
        
        let item1 = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1/5),
                              heightDimension: .fractionalHeight(1/2)
        ))
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1),
                              heightDimension: .fractionalWidth(0.3)),
            subitems: [item0, item1])
        
        let section = NSCollectionLayoutSection(group: group)
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1),
                              heightDimension: .absolute(30)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        
        let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "section-background-element-kind")
        
        section.interGroupSpacing = -30
        section.decorationItems = [decorationItem]
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func mainSectionConfigure() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1),
                              heightDimension: .fractionalHeight(1)
        ))
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1),
                              heightDimension: .fractionalWidth(0.6)),
            subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "section-background-element-kind")
        
        section.decorationItems = [decorationItem]
        
        return section
    }
    
    enum Section: Int, CaseIterable {
        case main, clothes, forecastList, tenDayForecast
    }

}
