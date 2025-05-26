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
        
        // 메인 셀 데이터가 불러와지면
        viewModel.output.mainCellData
            .subscribe { [weak self] _ in
                self?.weatherCollectionView.reloadData()
            }.disposed(by: disposeBag)
        
        // tenDayForecastCell 데이터가 불러와지면
        viewModel.output.tenDayForecastCellData
            .subscribe { [weak self] _ in
                self?.weatherCollectionView.reloadData()
            }.disposed(by: disposeBag)
        
        // customForecast 데이터 변환 작업이 끝나면
        viewModel.output.customForecastData
            .subscribe { [weak self] _ in
                self?.weatherCollectionView.reloadData()
            }.disposed(by: disposeBag)
    }
    
    // MainViewModel에게 Input을 보내는 메서드
    private func inputBind() {
        self.navigationItem.leftBarButtonItem?.rx.tap.subscribe { [weak self] _ in
            guard let self else { return }
            self.viewModel.input.accept(.settingButtonTap)
        }.disposed(by: disposeBag)
    }
    
    // UI 세팅 메서드
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
    
    // 섹션 개수
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }
    
    // 섹션별 셀 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .main: return 1
        case .clothes: return 1
        case .forecastList: return self.viewModel.output.tenDayForecastCellData.value?.forecastList.count ?? 0
        case .tenDayForecast: return self.viewModel.output.customForecastData.value?.count ?? 0
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
                
            cell.setText(weather: weather)
            cell.setMinMaxTempForDay(temp: customForecast[indexPath.row].forecastList)
            
            return cell
        case .clothes:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ClothesCell.identifier, for: indexPath) as? ClothesCell else { return .init() }
            
            cell.test()
            
            return cell
        case .forecastList:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ForecastListCell.identifier, for: indexPath) as? ForecastListCell else { return .init() }
            
            guard let data = self.viewModel.output.tenDayForecastCellData.value else { return cell }
            
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
            
            guard let customData = self.viewModel.output.customForecastData.value else { return cell }
            guard let forecast = self.viewModel.output.tenDayForecastCellData.value else { return cell }
            
            cell.setCell(data: customData[indexPath.row].forecastList, image: customData[indexPath.row].weatherIcons)
            
            if indexPath.row == 0 {
                // 첫 번째 셀
                // 현재 온도를 표시할 메서드
                cell.setCurrentTemp(data: forecast.forecastList[indexPath.row])
            } else if indexPath.row == 9 {
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
