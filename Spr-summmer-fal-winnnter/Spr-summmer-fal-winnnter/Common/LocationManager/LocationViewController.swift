//
//  LocationViewController.swift
//  Spr-summmer-fal-winnnter
//
//  Created by NH on 5/21/25.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    let locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("현재 주소 가져오기", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let addressLabel: UILabel = {
        let label = UILabel()
        label.text = "주소가 여기에 표시됩니다"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        bindLocationManager()
    }

    func setupUI() {
        view.addSubview(locationButton)
        view.addSubview(addressLabel)

        NSLayoutConstraint.activate([
            locationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            locationButton.heightAnchor.constraint(equalToConstant: 50),

            addressLabel.topAnchor.constraint(equalTo: locationButton.bottomAnchor, constant: 30),
            addressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        locationButton.addTarget(self, action: #selector(didTapLocationButton), for: .touchUpInside)
    }

    func bindLocationManager() {
        LocationManager.shared.addressSubject
            .subscribe(onNext: { [weak self] address in
                self?.addressLabel.text = "주소: \(address)"
            }).disposed(by: disposeBag)
        
        LocationManager.shared.errorSubject
            .subscribe(onNext: { [weak self] error in
                self?.addressLabel.text = "오류: \(error)"
            }).disposed(by: disposeBag)

    }

    @objc func didTapLocationButton() {
        LocationManager.shared.requestLocation()
    }
}
