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
    
    let locationViewModel = LocationViewModel()
    lazy var viewModel = MainViewModel(locationViewModel: locationViewModel)
    
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
    
    private let clothesViewModel = ClothesViewModel()

}

// MARK: - Lifecycle
extension MainViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        inputBind()
        LocationManager.shared.requestLocation()
        
        //출력 확인용
        //clothesViewModel.update(temp: 4.0, condition: "Clear")     // very cold
        //clothesViewModel.update(temp: 12.0, condition: "Clear")    // cool
        //clothesViewModel.update(temp: 20.0, condition: "Clear")    // mild
        //clothesViewModel.update(temp: 26.0, condition: "Clear")    // warm
        //clothesViewModel.update(temp: 31.0, condition: "Clear")    // hot
        //clothesViewModel.update(temp: 18.0, condition: "Rain")     // rain
        //clothesViewModel.update(temp: -2.0, condition: "Snow")     // snow
        reloadMainCellData()
    }
}

// MARK: - Method
extension MainViewController {
    
    // MainViewModel의 Output을 구독하는 메서드
    private func bind() {
        // 세팅 버튼 클릭 시
        viewModel.output.showSettingMenu
            .subscribe { [weak self] _ in
                guard let self else { return }
                self.viewModel.showSettingMenu(on: self)
            }.disposed(by: disposeBag)
        
        // 검색 버튼 클릭 시 검색 뷰로 이동
        viewModel.output.showSearchView
            .subscribe { [weak self] _ in
                guard let self else { return }
                let searchVC = SearchViewController(
                    viewModel: self.locationViewModel,
                    mainViewModel: self.viewModel
                )
                self.navigationController?.pushViewController(searchVC, animated: true)
            }.disposed(by: disposeBag)
        
        // 메인 셀 데이터가 불러와지면
        // MARK: - 기존 코드

        viewModel.output.mainCellData
            .subscribe { [weak self] _ in
                self?.weatherCollectionView.reloadData()
            }.disposed(by: disposeBag)
        
        viewModel.output.forecastListCellData
            .subscribe { [weak self] weather in
                guard let self else { return }
                
                self.weatherCollectionView.reloadData()
            }.disposed(by: disposeBag)
        
        // customForecast 데이터 변환 작업이 끝나면
        viewModel.output.customForecastData
            .subscribe { [weak self] _ in
                self?.weatherCollectionView.reloadData()

            }.disposed(by: disposeBag)
        
        viewModel.tempUnit
            .subscribe { [weak self] _ in
                self?.weatherCollectionView.reloadData()
            }.disposed(by: disposeBag)
    }
    
    // MainViewModel에게 Input을 보내는 메서드
    private func inputBind() {
        // 메뉴버튼 클릭
        self.navigationItem.leftBarButtonItem?.rx.tap.subscribe { [weak self] _ in
            guard let self else { return }
            self.viewModel.input.accept(.settingButtonTap)
        }.disposed(by: disposeBag)
        
        // 검색 버튼 클릭
        self.navigationItem.rightBarButtonItem?.rx.tap.subscribe{ [weak self] _ in
            guard let self else { return }
            self.viewModel.input.accept(.searchButtonTap)
        }.disposed(by: disposeBag)
        
        /// - 좌표 정보 구독
        /// - 좌표 정보가 바뀌면 좌표 정보를 viewModel에 전달
        /// - input에도 정보 전달
        LocationManager.shared.coordinateSubject
            .subscribe { [weak self] coordinate in
                guard let self else { return }
                guard let coordinate else { return }
                self.viewModel.latitude.accept("\(coordinate.latitude)")
                self.viewModel.longitude.accept("\(coordinate.longitude)")
                self.viewModel.input.accept(.changeCoordinate)
            }.disposed(by: disposeBag)
    }

    private func setupUI() {
        let menuButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal"),
            style: .plain,
            target: nil,
            action: nil)
        menuButton.tintColor = .black
        
        self.navigationItem.leftBarButtonItem = menuButton
        
        let searchButton = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: nil,
            action: nil
        )
        searchButton.tintColor = .black
        
        self.navigationItem.rightBarButtonItem = searchButton
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 140/255, green: 216/255, blue: 219/255, alpha: 1.0)
        
        view.backgroundColor = UIColor(red: 140/255, green: 216/255, blue: 219/255, alpha: 1.0)
        view.addSubview(weatherCollectionView)
        
        weatherCollectionView.snp.makeConstraints {
            $0.height.width.equalTo(view.safeAreaLayoutGuide)
            $0.center.equalToSuperview()
        }
    }
    
    /// pull to refresh
    private func reloadMainCellData() {
        
        weatherCollectionView.rx.didEndDragging
            .filter { $0 } // 사용자가 손을 뗐을 때만
            .observe(on: MainScheduler.instance)
            .map { [weak self] _ in
                guard let self else { return 0 }
                return self.weatherCollectionView.contentOffset.y
            }
            .filter { yOffset in
                yOffset < -210 // 위로 잡아 당긴 높이
            }
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }

                self.viewModel.applyDummyData() // 더미 데이터 및 날씨 요청
                self.viewModel.input.accept(.changeCoordinate) // 위지 정보 요청
                self.weatherCollectionView.reloadData() // 데이터 UI에 리로드
            }).disposed(by: disposeBag)
    }
    
}

// MARK: - CollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    
}

// MARK: - CollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    
    // 섹션 개수
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }
    
    // 섹션별 셀 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .main: return 1
        case .clothes: return 1
        case .tenDayForecast: return self.viewModel.output.customForecastData.value?.count ?? 0
        case .forecastList: return self.viewModel.output.forecastListCellData.value?.forecastList.count ?? 0
        case .none: return 0
        }
    }
    
    // 셀에 표시할 아이템
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch Section(rawValue: indexPath.section) {
        case .main:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCell.identifier, for: indexPath) as? MainCell else { return .init() }
            
            guard let weather = viewModel.output.mainCellData.value else { return cell }
            guard let customForecast = self.viewModel.output.customForecastData.value else { return cell }
            
            cell.setText(weather: weather, tempUnit: self.viewModel.tempUnit.value)
            cell.setMinMaxTempForDay(temp: customForecast[indexPath.row].forecastList, tempUnit: self.viewModel.tempUnit.value)
            
            // 여기서 주소도 전달
            cell.bindAddress(with: locationViewModel)
            
            return cell
            
        case .clothes:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ClothesCell.identifier, for: indexPath) as? ClothesCell else { return .init() }
            
            // 날씨 데이터 가져오기
                if let weather = viewModel.output.mainCellData.value {
                    let temp = weather.main.temp
                    let condition = weather.weather.first?.main ?? "Clear"
                    let unit = viewModel.tempUnit.value

                    // ViewModel 업데이트
                    clothesViewModel.update(temp: temp, condition: condition, tempUnit: unit)
                }

            // ViewModel에서 추천 옷 정보 가져와 셀에 적용
            if let recommendation = clothesViewModel.recommendation.value {
                let message = clothesViewModel.message.value
                cell.configure(with: recommendation, message: message)
            }

            
            return cell
            
        case .forecastList:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ForecastListCell.identifier, for: indexPath) as? ForecastListCell else { return .init() }
            
            guard let data = self.viewModel.output.forecastListCellData.value else { return cell }
            
                cell.setCell(data: data.forecastList[indexPath.row],
                             icon: data.weatherIcons[indexPath.row], tempUnit: self.viewModel.tempUnit.value)
            
            return cell
        case .tenDayForecast:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TenDayForecastCell.identifier, for: indexPath) as? TenDayForecastCell else { return .init() }
            
            guard let customData = self.viewModel.output.customForecastData.value else { return cell }
            guard let currentTemp = self.viewModel.output.forecastListCellData.value?.forecastList[0].main.temp else { return cell }
            
            cell.setCell(currentTemp: currentTemp,
                         data: customData[indexPath.row].forecastList,
                         image: customData[indexPath.row].weatherIcons, tempUnit: self.viewModel.tempUnit.value)
            
            if indexPath.row == 0 {
                // 첫 번째 셀
                // 현재 온도를 표시할 메서드
                cell.setToday()
            } else if indexPath.row == 4 {
                // 마지막 셀
                // 구분선을 숨기는 메서드
                cell.deleteSeparator()
            }
            
            return cell
        case .none:
            return .init()
        }
    }
    
    // CollectionViewLayout 섹션을 합쳐 레이아웃 반환
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
        
        // 셀 백그라운드 데코레이션 아이템
        layout.register(CellBackground.self, forDecorationViewOfKind: "section-background-element-kind")
        
        return layout
    }
    
    // tenDayForecast섹션 레이아웃
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
        section.contentInsets = .init(top: 10, leading: 40, bottom: 10, trailing: 40)
        
        let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "section-background-element-kind")
        
        section.decorationItems = [decorationItem]
        
        return section
    }
    
    // ForecastList 섹션 레이아웃
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
        section.contentInsets = .init(top: 0, leading: 30, bottom: 0, trailing: 30)
        
        return section
    }
    
    // 메인, 옷 추천 섹션 레이아웃
    private func mainSectionConfigure() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1),
                              heightDimension: .fractionalHeight(1)
        ))
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1),
                              heightDimension: .fractionalWidth(0.55)),
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
