//
//  TempProgressBar.swift
//  Spr-summmer-fal-winnnter
//
//  Created by 최규현 on 5/22/25.
//

import UIKit
import SnapKit
import Foundation

// MARK: - TempProgressBar
// tenDayForecastCell의 온도 그래프 커스텀
class TempProgressBar: UIView {
    
    // 그래프 기준 온도
    private let sysMinForCelsius: Double = 10
    private let sysMaxForCelsius: Double = 30
    
    private var sysMinForFahrenheit: Double {
        (sysMinForCelsius * 9 / 5) + 32
    }
    private var sysMaxForFahrenheit: Double {
        (sysMaxForCelsius * 9 / 5) + 32
    }
    
    private let backgroundBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
        view.clipsToBounds = true
        view.layer.cornerRadius = 2.5
        
        return view
    }()
    
    private let fillBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7)
        view.clipsToBounds = true
        view.layer.cornerRadius = 2.5
        
        return view
    }()
    
    private let currentTempPoint: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 2.5
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(backgroundBar)
        backgroundBar.addSubview(fillBar)
        backgroundBar.addSubview(currentTempPoint)
        
        backgroundBar.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(5)
        }
    }
    
    // 기온에 맞게 파란 영역, 흰색 포인트를 잡아주는 메서드
    func update(currentTemp: Double, minTemp: Double, maxTemp: Double, tempUnit: Int) {
        var sysMin = self.sysMinForCelsius
        var sysMax = self.sysMaxForCelsius
        
        if tempUnit == 1 {
            sysMin = self.sysMinForFahrenheit
            sysMax = self.sysMaxForFahrenheit
        }
        
        let sysRange = (Int(sysMin)...Int(sysMax)).count
        let tempRange = (Int(minTemp)...Int(maxTemp)).count
        
        let width = CGFloat(Double(tempRange) / Double(sysRange))
        
        layoutIfNeeded() // 레이아웃 강제 적용(frame 값을 받아 쓰기 위해)
        let persent = CGFloat(abs(minTemp - sysMin) / Double(sysRange))
        let leading = persent * backgroundBar.frame.width
        let currentPersent = CGFloat(abs(currentTemp - sysMin) / Double(sysRange))
        let currentLeading = currentPersent * backgroundBar.frame.width
        
        currentTempPoint.snp.remakeConstraints {
            $0.width.height.equalTo(5)
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(currentLeading)
        }
        fillBar.snp.remakeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(leading)
            $0.width.equalToSuperview().multipliedBy(width)
        }
        
        currentTempPoint.isHidden = true
        
        layoutIfNeeded() // 레이아웃 강제 적용
    }
    
    // 현재 기온의 포인트를 표시하는 메서드
    func setCurrentPoint() {
        currentTempPoint.isHidden = false
    }
}

