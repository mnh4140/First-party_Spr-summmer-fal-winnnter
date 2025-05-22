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
    
    private let dustStateLabel: UILabel = {
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
        dustStateLabel.text = "맑음"
        maxTempLabel.text = "27'"
        minTempLabel.text = "19'"
    }
    
    func setText(weather: WeatherResponse) {
        cityLabel.text = weather.name
        tempLabel.text = "\(weather.main.temp)"
        dustStateLabel.text = weather.weather[0].main
        maxTempLabel.text = "\(weather.main.tempMax)"
        minTempLabel.text = "\(weather.main.tempMin)"
    }
    
    private func setupUI() {
        [maxTempLabel, minTempLabel]
            .forEach { maxMinTempStackView.addArrangedSubview($0) }
        
        [cityLabel, tempLabel, dustStateLabel, maxMinTempStackView]
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
