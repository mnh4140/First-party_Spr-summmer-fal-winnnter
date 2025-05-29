//
//  ForecastListCell.swift
//  Spr-summmer-fal-winnnter
//
//  Created by 최규현 on 5/21/25.
//

import UIKit
import SnapKit

class ForecastListCell: UICollectionViewCell {
    static let identifier = "ForecastListCell"
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .white
        
        return label
    }()
    
    private let weatherIcon: UIImageView = {
        let ImageView = UIImageView()
        
        return ImageView
    }()
    
    private let tempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .white
        
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCell(data: ForecastList, icon: UIImage, tempUnit: Int) {
        timeLabel.text = self.changeDate(data: data)
        let tempResult = tempUnit == 0 ? "°C" : "°F"
        tempLabel.text = "\(Int(data.main.temp))" + tempResult
        weatherIcon.image = icon
    }
    
    private func changeDate(data: ForecastList) -> String {
        // dt에 저장된 Unix timestamp를 Date타입으로 변환
        let customDate = Date(timeIntervalSince1970: Double(data.dt))
        
        // DateFormatter 생성
        let customDateFormatter = DateFormatter()
        // DateFormatter의 포맷을 "시간+AM or PM"으로 설정
        customDateFormatter.dateFormat = "ha"
        // DateFormat 실행
        let hour = customDateFormatter.string(from: customDate)
        
        return hour
    }
    
    private func setupUI() {
        [weatherIcon, tempLabel]
            .forEach { stackView.addArrangedSubview($0) }
        
        [timeLabel, stackView]
            .forEach { contentView.addSubview($0) }
        
        timeLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(contentView.snp.centerY)//.offset(-2)
        }
        
        weatherIcon.snp.makeConstraints {
            $0.width.height.equalTo(16)
        }
        
        stackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(contentView.snp.centerY)//.offset(2)
        }
    }
}
