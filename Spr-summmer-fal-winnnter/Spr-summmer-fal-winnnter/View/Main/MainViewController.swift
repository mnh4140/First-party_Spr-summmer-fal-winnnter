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
    
    let locationViewModel = ViewModel()
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
}

// MARK: - Lifecycle
extension MainViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("🌆 [메인 뷰컨] MainViewController viewDidLoad")
        setupUI()
        bind()
        inputBind()
        //bindLocationManager()
        LocationManager.shared.requestLocation()
        //cellSelect()
        reloadMainCellData()
    }
}

// MARK: - Method
extension MainViewController {
    
    // MainViewModel의 Output을 구독하는 메서드
    private func bind() {
        // 세팅 버튼 클릭 시
        //print("\t🌆 [메인 뷰컨] bind 호출")
        viewModel.output.showSettingMenu
            .subscribe { [weak self] _ in
                guard let self else { return }
                self.viewModel.showSettingMenu(on: self)
                //print("\t\t🌆 [메인 뷰컨] output.showSettingMenu 호출")
            }.disposed(by: disposeBag)
        
        viewModel.output.showSearchView
            .subscribe { [weak self] _ in
                guard let self else { return }
                let searchVC = SearchViewController(
                    viewModel: self.locationViewModel,
                    mainViewModel: self.viewModel
                )
//                searchVC.viewModel = self.locationViewModel // 같은 인스턴스 전달
//                searchVC.mainViewModel = self.viewModel
                self.navigationController?.pushViewController(searchVC, animated: true)
            }.disposed(by: disposeBag)
        
        // 메인 셀 데이터가 불러와지면
        // MARK: - 기존 코드

        viewModel.output.mainCellData
            .subscribe { [weak self] _ in
                self?.weatherCollectionView.reloadData()
                //print("\t\t🌆 [메인 뷰컨] output.mainCellData 호출")
            }.disposed(by: disposeBag)
        
        viewModel.output.NOHUNforecastListCellData
            .subscribe { [weak self] weather in
                guard let self else { return }
                
                self.weatherCollectionView.reloadData()
                //print("\t\t🌆 [메인 뷰컨] output.NOHUNforecastListCellData 호출")
            }.disposed(by: disposeBag)

        viewModel.output.tenDayForecastCellData
            .subscribe { [weak self] _ in
                self?.weatherCollectionView.reloadData()
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
            //print("\t\t🌆 [메인 뷰컨] 설정 버튼 클릭됨")
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
//                self.viewModel.latitude = "\(coordinate.latitude)"
//                self.viewModel.longitude = "\(coordinate.longitude)"
                guard let coordinate else { return }
                self.viewModel.latitude.accept("\(coordinate.latitude)")
                self.viewModel.longitude.accept("\(coordinate.longitude)")
                self.viewModel.input.accept(.changeCoordinate)
                //print("\t\t🌆 [메인 뷰컨] 좌표 변경 감지")
            }.disposed(by: disposeBag)
    }
    
    /// 메인셀 선택 시, 검색 화면으로 넘어가는 기능
//    func cellSelect() {
//        //print("\t🌆 [메인 뷰컨] cellSelect 호출")
//        weatherCollectionView.rx.itemSelected
//            .subscribe(onNext: { indexPath in
//                if MainViewController.Section(rawValue: indexPath.section) == .main {
//                    //print("\t\t🌆 [메인 뷰컨] 메인 셀이 눌렸습니다.")
//                    let searchVC = SearchViewController()
//                        searchVC.viewModel = self.locationViewModel // 같은 인스턴스 전달
//                    searchVC.mainViewModel = self.viewModel
//                    self.navigationController?.pushViewController(searchVC, animated: true)
//                }
//            }).disposed(by: disposeBag)
//        
//        
//    }

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
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 154/255, green: 203/255, blue: 208/255, alpha: 1.0)
        
        view.backgroundColor = UIColor(red: 154/255, green: 203/255, blue: 208/255, alpha: 1.0)
        view.addSubview(weatherCollectionView)
        
        weatherCollectionView.snp.makeConstraints {
            $0.height.width.equalTo(view.safeAreaLayoutGuide)
            $0.center.equalToSuperview()
        }
    }
    
    /// pull to refresh
    private func reloadMainCellData() {
        
        var isEnd: Bool = false
        
        weatherCollectionView.rx.didEndDecelerating
            .subscribe(onNext: {
                print("스크롤 완전히 멈춤")
                isEnd = true
            })
            .disposed(by: disposeBag)
        
        weatherCollectionView.rx.contentOffset
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] contentOffset in
                guard let self = self else { return }
                //let contentHeight = self.weatherCollectionView.contentSize.height
                //let height = self.weatherCollectionView.frame.size.height
                let yOffset = contentOffset.y
                //print("yOffset : \(yOffset)")
                //print("height : \(height)")
                //print("contentHeight : \(contentHeight)")
                // 바닥에 도달했는지 판단
                if yOffset < -210  && isEnd {
                    print("스크롤 동작")
                    
                    // 더미 데이터 넣기
                    self.viewModel.applyDummyData()
                    
                    LocationManager.shared.coordinateSubject
                        .subscribe(onNext: { coordinate in
                            self.viewModel.input.accept(.changeCoordinate)
                        }).disposed(by: self.disposeBag)
                   
                    
                    self.weatherCollectionView.reloadData()
                    
                    print("데이터 갱신")
                    
                    isEnd = false
                }
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
        case .forecastList: return self.viewModel.output.NOHUNforecastListCellData.value?.forecastList.count ?? 0
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
            
            cell.test()
            
            return cell
        case .forecastList:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ForecastListCell.identifier, for: indexPath) as? ForecastListCell else { return .init() }
            
            guard let data = self.viewModel.output.NOHUNforecastListCellData.value else { return cell }
            
                cell.setCell(data: data.forecastList[indexPath.row],
                             icon: data.weatherIcons[indexPath.row], tempUnit: self.viewModel.tempUnit.value)
            
            return cell
        case .tenDayForecast:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TenDayForecastCell.identifier, for: indexPath) as? TenDayForecastCell else { return .init() }
            
            guard let customData = self.viewModel.output.customForecastData.value else { return cell }
            guard let currentTemp = self.viewModel.output.NOHUNforecastListCellData.value?.forecastList[0].main.temp else { return cell }
            
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
        section.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)
        
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
