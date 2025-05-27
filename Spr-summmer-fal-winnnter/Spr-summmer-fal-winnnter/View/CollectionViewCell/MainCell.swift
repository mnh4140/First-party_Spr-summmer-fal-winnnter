//
//  CollectionViewCell.swift
//  Spr-summmer-fal-winnnter
//
//  Created by 최규현 on 5/21/25.
//

import UIKit
import SnapKit
import RxSwift

class MainCell: UICollectionViewCell {
    static let identifier = "MainCell"
    
    var disposeBag = DisposeBag()
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.text = "도시 이름이 나타납니다."
        label.font = .systemFont(ofSize: 32)
        label.textColor = .white
        label.textAlignment = .center
        
        return label
    }()
    
    private let tempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 64)
        label.textColor = .white
        label.textAlignment = .center
        
        return label
    }()
    
    private let weatherLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textColor = .white
        label.textAlignment = .center
        
        return label
    }()
    
    private let maxTempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textColor = .white
        label.textAlignment = .center
        
        return label
    }()
    
    private let minTempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textColor = .white
        label.textAlignment = .center
        
        return label
    }()
    
    private let maxMinTempStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setText(weather: WeatherResponse, tempUnit: Int) {
        //cityLabel.text = weather.name
        let tempResult = tempUnit == 0 ? "°C" : "°F"
        tempLabel.text = "\(Int(weather.main.temp))" + tempResult
        weatherLabel.text = weather.weather[0].main
    }
    
    func setMinMaxTempForDay(temp: CustomForecastList, tempUnit: Int) {
        let tempResult = tempUnit == 0 ? "°C" : "°F"
        minTempLabel.text = "\(Int(temp.tempMin))" + tempResult
        maxTempLabel.text = "\(Int(temp.tempMax))" + tempResult
    }
    
    /// [위치] 주소 정보 바인딩
    func bindAddress(with viewModel: LocationViewModel) {
        viewModel.regionCodeRelay
            .asDriver(onErrorJustReturn: [])
            .map {
                guard let region2DepthName = $0.first?.region2DepthName else { return "주소 없음" }
                guard let region3DepthName = $0.first?.region3DepthName else { return "주소 없음" }
                
                return region2DepthName + " " + region3DepthName
            }
            .drive(cityLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        [minTempLabel, maxTempLabel]
            .forEach { maxMinTempStackView.addArrangedSubview($0) }
        
        [cityLabel, tempLabel, weatherLabel, maxMinTempStackView]
            .forEach { stackView.addArrangedSubview($0) }
        
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        maxMinTempStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
        }
        
    }
    
}
