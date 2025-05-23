//
//  LocationViewController.swift
//  Spr-summmer-fal-winnnter
//
//  Created by NH on 5/21/25.
//

import UIKit
import RxSwift
import SnapKit

class ViewController: UIViewController {

    let locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("검색", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let addressLabel: UILabel = {
        let label = UILabel()
        //label.text = "주소가 여기에 표시됩니다"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var disposeBag = DisposeBag()
    
    let viewModel = ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        bindLocationManager()
        bindViewModel()
        LocationManager.shared.requestLocation() // 위치 요청
    }

    func setupUI() {
        view.addSubview(locationButton)
        view.addSubview(addressLabel)
        
        locationButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(50)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(locationButton.snp.bottom).offset(20)
            make.centerX.equalTo(locationButton.snp.centerX)
            make.height.equalTo(50)
        }

        locationButton.addTarget(self, action: #selector(didTapLocationButton), for: .touchUpInside)
    }

    func bindLocationManager() {
        LocationManager.shared.coordinateSubject
            .subscribe(onNext: { [weak self] coordinate in
                let longitude = "\(coordinate.longitude)"
                let latitude = "\(coordinate.latitude)"
                self?.viewModel.fetchRegionCode(longitude: longitude, latitude: latitude)
            })
            .disposed(by: disposeBag)

        LocationManager.shared.errorSubject
            .subscribe(onNext: { [weak self] error in
                self?.addressLabel.text = "오류: \(error)"
            })
            .disposed(by: disposeBag)
    }
    
    func bindViewModel() {
        viewModel.regionCodeRelay
            .asDriver(onErrorJustReturn: [])
            .map { $0.first?.addressName ?? "주소 없음" }
            .drive(addressLabel.rx.text)
            .disposed(by: disposeBag)
    }

    @objc func didTapLocationButton() {
        LocationManager.shared.requestLocation()
        navigationController?.pushViewController(SearchViewController(), animated: true)
    }
}
