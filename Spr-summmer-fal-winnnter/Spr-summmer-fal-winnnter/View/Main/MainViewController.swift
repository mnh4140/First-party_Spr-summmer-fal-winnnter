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
    private var collectionViewDataSource: UICollectionViewDiffableDataSource<MainViewModel.Section, MainViewModel.Item>?
    
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
        configureCellDataSource()
        configureHeaderDataSource()
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
                self?.viewModel.updateSnapshot()
            }.disposed(by: disposeBag)
        
        viewModel.output.forecastListCellData
            .subscribe { [weak self] weather in
                guard let self else { return }
                
                self.viewModel.updateSnapshot()
            }.disposed(by: disposeBag)
        
        viewModel.output.tenDayForecastCellData
            .subscribe { [weak self] _ in
                self?.viewModel.updateSnapshot()
            }.disposed(by: disposeBag)
        
        // customForecast 데이터 변환 작업이 끝나면
        viewModel.output.customForecastData
            .subscribe { [weak self] _ in
                self?.viewModel.updateSnapshot()
                
            }.disposed(by: disposeBag)
        
        viewModel.tempUnit
            .subscribe { [weak self] _ in
                self?.viewModel.updateSnapshot()
            }.disposed(by: disposeBag)
        
        viewModel.output.snapshotRelay
            .subscribe { [weak self] snapshot in
                guard let self, let snapshot else { return }
                self.collectionViewDataSource?.apply(snapshot)
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
                guard let self, let coordinate else { return }
                self.viewModel.latitude.accept("\(coordinate.latitude)")
                self.viewModel.longitude.accept("\(coordinate.longitude)")
                self.viewModel.input.accept(.changeCoordinate)
            }.disposed(by: disposeBag)
    }
    
    private func configureCellDataSource() {
        self.collectionViewDataSource = UICollectionViewDiffableDataSource(collectionView: self.weatherCollectionView,
                                                                           cellProvider: { collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier {
            case .mainCell(let weather):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCell.identifier, for: indexPath) as? MainCell else { return .init() }
                
                guard let weather else { return .init() }
                
                cell.setText(weather: weather.weatherResponse, tempUnit: self.viewModel.tempUnit.value)
                cell.setMinMaxTempForDay(temp: weather.customForecastData, tempUnit: self.viewModel.tempUnit.value)
                
                // 여기서 주소도 전달
                cell.bindAddress(with: self.locationViewModel)
                
                return cell
            case .clothesCell(let weather):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ClothesCell.identifier, for: indexPath) as? ClothesCell else { return .init() }
                
                // 날씨 데이터 가져오기
                if let weather {
                    let temp = weather.weatherResponse.main.temp
                    let condition = weather.weatherResponse.weather.first?.main ?? "Clear"
                    let unit = self.viewModel.tempUnit.value
                    
                    // ViewModel 업데이트
                    self.clothesViewModel.update(temp: temp, condition: condition, tempUnit: unit)
                }
                
                //출력 확인용
                //clothesViewModel.update(temp: 4.0, condition: "Clear")     // very cold
                //clothesViewModel.update(temp: 12.0, condition: "Clear")    // cool
                //clothesViewModel.update(temp: 20.0, condition: "Clear")    // mild
                //clothesViewModel.update(temp: 26.0, condition: "Clear")    // warm
                //clothesViewModel.update(temp: 31.0, condition: "Clear", tempUnit: viewModel.tempUnit.value)    // hot
                //clothesViewModel.update(temp: 18.0, condition: "Rain", tempUnit: viewModel.tempUnit.value)     // rain
                //clothesViewModel.update(temp: -2.0, condition: "Snow", tempUnit: viewModel.tempUnit.value)     // snow

                // ViewModel에서 추천 옷 정보 가져와 셀에 적용
                if let recommendation = self.clothesViewModel.recommendation.value {
                    let message = self.clothesViewModel.message.value
                    cell.configure(with: recommendation, message: message)
                }
                
                return cell
                
            case .forecastCell(let data):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ForecastListCell.identifier, for: indexPath) as? ForecastListCell else { return .init() }
                
                guard let data else { return .init() }
                
                cell.setCell(data: data.forecastList,
                             icon: data.weatherIcons, tempUnit: self.viewModel.tempUnit.value)
                
                return cell
                
            case .tenDayForecastCell(let customData):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TenDayForecastCell.identifier, for: indexPath) as? TenDayForecastCell else { return .init() }
                
                guard let customData else { return .init() }
                guard let currentTemp = self.viewModel.output.forecastListCellData.value?.forecastList[0].main.temp else { return cell }
                
                cell.setCell(currentTemp: currentTemp,
                             data: customData.forecastList,
                             image: customData.weatherIcons, tempUnit: self.viewModel.tempUnit.value)
                
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
            }
        })
    }
    
    private func configureHeaderDataSource() {
        self.collectionViewDataSource?.supplementaryViewProvider = { collectionView,  kind, indexPath in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
            
            return header
        }
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
                LocationManager.shared.requestLocation()
                self.viewModel.input.accept(.changeCoordinate) // 위지 정보 요청
                self.weatherCollectionView.reloadData() // 데이터 UI에 리로드
            }).disposed(by: disposeBag)
    }
    
}

// MARK: - CollectionViewLayout
extension MainViewController {
    
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
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 10
        
        layout.configuration = config
        
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
                              heightDimension: .fractionalWidth(0.25)),
            subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 40, bottom: 10, trailing: 40)
        
        let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "section-background-element-kind")
        
        section.decorationItems = [decorationItem]
        
        return section
    }
    
    // ForecastList 섹션 레이아웃
    private func forecastListSectionConfigure() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1/5),
                              heightDimension: .fractionalHeight(1/1)
                             ))
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1),
                              heightDimension: .fractionalWidth(0.25)),
            subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "section-background-element-kind")
        
        section.contentInsets = .init(top: 10, leading: 30, bottom: 10, trailing: 30)
        section.decorationItems = [decorationItem]
        
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
                              heightDimension: .fractionalWidth(0.5)),
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
