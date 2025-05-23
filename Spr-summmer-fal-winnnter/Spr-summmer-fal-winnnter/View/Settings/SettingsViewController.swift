//
//  SettingsViewController.swift
//  Spr-summmer-fal-winnnter
//
//  Created by NH on 5/21/25.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa

// MARK: - SettingsViewController
class SettingsViewController: UIViewController {
    
    // Property
//    private let disposeBag = DisposeBag()
//    private let viewModel = MainViewModel()
    
    // MARK: - UIProperty
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "설정"
        label.font = .systemFont(ofSize: 20)
        label.textColor = .black
        
        return label
    }()
    
    private let tempLabel: UILabel = {
        let label = UILabel()
        label.text = "온도 단위 변경하기"
        label.font = .systemFont(ofSize: 20)
        label.textColor = .black
        
        return label
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Celsius", "Fahrenheit"])
        segmentedControl.selectedSegmentIndex = 0
        
        return segmentedControl
    }()
    
    private let darkModeLabel: UILabel = {
        let label = UILabel()
        label.text = "다크모드"
        label.font = .systemFont(ofSize: 20)
        label.textColor = .black
        
        return label
    }()
    
    private let switchButton: UISwitch = {
        let switchButton = UISwitch()
        
        return switchButton
    }()
    
    private let adLabel: UILabel = {
        let label = UILabel()
        label.text = "광고로부터 벗어나기"
        label.font = .systemFont(ofSize: 20)
        label.textColor = .black
        
        return label
    }()
    
    private let removeAdButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("결제하기", for: .normal)
        
        return button
    }()
    
}

// MARK: - Lifecycle
extension SettingsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
}

// MARK: - Method
extension SettingsViewController {
    
    private func setupUI() {
        view.backgroundColor = .white
        
        [titleLabel, tempLabel, segmentedControl, darkModeLabel, switchButton, adLabel, removeAdButton]
            .forEach { view.addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        
        tempLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(48)
            $0.leading.equalTo(titleLabel)
        }
        
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(tempLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        darkModeLabel.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(48)
            $0.leading.equalTo(titleLabel)
        }
        
        switchButton.snp.makeConstraints {
            $0.centerY.equalTo(darkModeLabel)
            $0.leading.equalTo(darkModeLabel.snp.trailing).offset(16)
        }
        
        adLabel.snp.makeConstraints {
            $0.top.equalTo(darkModeLabel.snp.bottom).offset(48)
            $0.leading.equalTo(titleLabel)
        }
        
        removeAdButton.snp.makeConstraints {
            $0.top.equalTo(adLabel.snp.bottom).offset(16)
            $0.centerX.equalTo(adLabel)
        }
    }
    
}
