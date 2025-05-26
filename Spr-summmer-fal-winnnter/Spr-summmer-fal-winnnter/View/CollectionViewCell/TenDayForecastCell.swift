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
        label.font = .systemFont(ofSize: 16, weight: .medium)
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
        label.adjustsFontSizeToFitWidth = true
        
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
    
    func setCell(currentTemp: Double, data: CustomForecastList, image: UIImage, tempUnit: Int) {
        dayLabel.text = "\(data.day)일"
        weatherImageView.image = image
        rainfallLabel.text = "\(data.pop * 100)%"
        let tempResult = tempUnit == 0 ? "°C" : "°F"
        minTempLabel.text = "\(Int(data.tempMin))" + tempResult
        maxTempLabel.text = "\(Int(data.tempMax))" + tempResult
        progressBar.update(currentTemp: currentTemp, minTemp: data.tempMin, maxTemp: data.tempMax)
    }
    
    func setToday() {
        dayLabel.text = "Today"
        progressBar.setCurrentPoint()
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
