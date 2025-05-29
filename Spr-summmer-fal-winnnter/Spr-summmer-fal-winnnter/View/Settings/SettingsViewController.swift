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
    private let disposeBag = DisposeBag()
    
    var viewModel: MainViewModel?
    
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
        let segmentedControl = UISegmentedControl(items: ["°C", "°F"])
        segmentedControl.selectedSegmentIndex = 0
        
        return segmentedControl
    }()
}

// MARK: - Lifecycle
extension SettingsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
    }
}

// MARK: - Method
extension SettingsViewController {
    
    private func bind() {
        segmentedControl.rx.selectedSegmentIndex
            .subscribe(onNext: { unit in
                self.viewModel?.input.accept(.setUnitButtonTap(unit))
            })
            .disposed(by: disposeBag)
        
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        [titleLabel, tempLabel, segmentedControl]
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
    }
    
}
