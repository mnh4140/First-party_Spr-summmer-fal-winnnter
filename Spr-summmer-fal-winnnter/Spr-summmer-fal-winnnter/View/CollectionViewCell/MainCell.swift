//
//  CollectionViewCell.swift
//  Spr-summmer-fal-winnnter
//
//  Created by 최규현 on 5/21/25.
//

import UIKit
import SnapKit

class MainCell: UICollectionViewCell {
    static let identifier = "MainCell"
    
    private let cityLabel: UILabel = {
        let label = UILabel()
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
    
    func test() {
        cityLabel.text = "도시"
        tempLabel.text = "19'"
        weatherLabel.text = "맑음"
        maxTempLabel.text = "27'"
        minTempLabel.text = "19'"
    }
    
    func setText(weather: WeatherResponse) {
        cityLabel.text = weather.name
        tempLabel.text = "\(Int(weather.main.temp))°C"
        weatherLabel.text = weather.weather[0].main
        minTempLabel.text = "\(Int(weather.main.tempMin))°C"
        maxTempLabel.text = "\(Int(weather.main.tempMax))°C"
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
