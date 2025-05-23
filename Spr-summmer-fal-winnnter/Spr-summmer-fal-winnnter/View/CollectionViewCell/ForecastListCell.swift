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
    
    func setFirstCell(data: ForecastList, icon: UIImage) {
        timeLabel.text = "Now"
        tempLabel.text = "\(Int(data.main.temp))°C"
        weatherIcon.image = icon
    }
    
    func setCell(data: ForecastList, icon: UIImage) {
        timeLabel.text = self.changeDate(data: data)
        tempLabel.text = "\(Int(data.main.temp))°C"
        weatherIcon.image = icon
    }
    
    private func changeDate(data: ForecastList) -> String {
        let date = data.dtTxt.components(separatedBy: " ")
        guard let hour = Int(String(date[1].prefix(2))) else { return "" }
        
        if hour > 12 {
            return "\(hour - 12)PM"
        } else {
            return "\(hour)AM"
        }
    }
    
    private func setupUI() {
        [weatherIcon, tempLabel]
            .forEach { stackView.addArrangedSubview($0) }
        
        [timeLabel, stackView]
            .forEach { contentView.addSubview($0) }
        
        timeLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(4)
        }
        
        weatherIcon.snp.makeConstraints {
            $0.width.height.equalTo(16)
        }
        
        stackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(4)
        }
    }
}
