//
//  TenDayForecast.swift
//  Spr-summmer-fal-winnnter
//
//  Created by 최규현 on 5/21/25.
//

import UIKit
import SnapKit

class TenDayForecastCell: UICollectionViewCell {
    static let identifier = "TenDayForecastCell"
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.textColor = .white
        
        return label
    }()
    
    private let weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let rainfallLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        
        return label
    }()
    
    private let verticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        
        return stack
    }()
    
    private let minTempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        
        return label
    }()
    
    private let progressBar: TempProgressBar = {
        let bar = TempProgressBar()
        
        return bar
    }()
    
    private let maxTempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func test() {
        let minTemp = 10.0
        let maxTemp = 27.0
        
        dayLabel.text = "Mon"
        weatherImageView.backgroundColor = .white
        rainfallLabel.text = "70%"
        minTempLabel.text = "\(minTemp)'"
        maxTempLabel.text = "\(maxTemp)'"
        progressBar.update(minTemp: minTemp, maxTemp: maxTemp)
    }
    
    func testFirstCell() {
        let currentTemp = 23.0
        
        progressBar.updateCurrent(currentTemp: currentTemp)
    }
    
    func setCell(data: ForecastList) {
        dayLabel.text = "Mon"
        weatherImageView.backgroundColor = .white
        rainfallLabel.text = "\(Int(data.pop * 100))%"
        minTempLabel.text = "\(data.main.tempMin)'"
        maxTempLabel.text = "\(data.main.tempMax)'"
        progressBar.update(minTemp: data.main.tempMin, maxTemp: data.main.tempMax)
    }
    
    func setCurrentTemp(data: ForecastList) {
        progressBar.updateCurrent(currentTemp: data.main.temp)
    }
    
    func deleteSeparator() {
        separatorView.isHidden = true
    }
    
    private func setupUI() {
        [weatherImageView, rainfallLabel]
            .forEach { verticalStackView.addArrangedSubview($0) }
        
        [dayLabel, verticalStackView, minTempLabel, progressBar, maxTempLabel, separatorView]
            .forEach { contentView.addSubview($0) }
        
        weatherImageView.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
        
        dayLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(24)
        }
        
        maxTempLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(24)
        }
        
        progressBar.snp.makeConstraints {
            $0.width.equalTo(80)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(maxTempLabel.snp.leading).offset(-8)
        }
        
        minTempLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(progressBar.snp.leading).offset(-8)
        }
        
        verticalStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(8)
            $0.trailing.equalTo(minTempLabel.snp.leading).offset(-16)
        }
        
        separatorView.snp.makeConstraints {
            $0.height.equalTo(0.5)
            $0.width.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
