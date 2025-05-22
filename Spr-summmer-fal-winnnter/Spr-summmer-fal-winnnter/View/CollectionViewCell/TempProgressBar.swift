//
//  TempProgressBar.swift
//  Spr-summmer-fal-winnnter
//
//  Created by 최규현 on 5/22/25.
//

import UIKit
import SnapKit
import Foundation

class TempProgressBar: UIView {
    
    private let sysMin: Double = 0
    private let sysMax: Double = 40
    
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
    
    func update(minTemp: Double, maxTemp: Double) {
        let sysRange = (Int(self.sysMin)...Int(self.sysMax)).count
        let tempRange = (Int(minTemp)...Int(maxTemp)).count
        
        let width = CGFloat(Double(tempRange) / Double(sysRange))
        
        layoutIfNeeded() // 레이아웃 강제 적용(frame 값을 받아 쓰기 위해)
        let persent = CGFloat(abs(minTemp - self.sysMin) / Double(sysRange))
        let leading = persent * backgroundBar.frame.width
        
        fillBar.snp.remakeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(leading)
            $0.width.equalToSuperview().multipliedBy(width)
        }
        
        layoutIfNeeded() // 레이아웃 강제 적용
    }
    
    func updateCurrent(currentTemp: Double) {
        let sysRange = (Int(self.sysMin)...Int(self.sysMax)).count
        
        layoutIfNeeded() // 레이아웃 강제 적용(frame 값을 받아 쓰기 위해)
        let currentPersent = CGFloat(abs(currentTemp - self.sysMin) / Double(sysRange))
        let currentLeading = currentPersent * backgroundBar.frame.width
        
        currentTempPoint.snp.makeConstraints {
            $0.width.height.equalTo(5)
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(currentLeading)
        }
        
        layoutIfNeeded() // 레이아웃 강제 적용
    }
}

