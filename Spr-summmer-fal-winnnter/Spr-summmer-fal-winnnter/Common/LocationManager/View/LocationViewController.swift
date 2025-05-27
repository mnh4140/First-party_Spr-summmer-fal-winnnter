////
////  LocationViewController.swift
////  Spr-summmer-fal-winnnter
////
////  Created by NH on 5/21/25.
////
//
//import UIKit
//import RxSwift
//import SnapKit
//
///// - 위치 테스트 용 뷰컨
//class ViewController: UIViewController {
//
//    let locationButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("검색", for: .normal)
//        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//
//    let addressLabel: UILabel = {
//        let label = UILabel()
//        //label.text = "주소가 여기에 표시됩니다"
//        label.font = .systemFont(ofSize: 24, weight: .bold)
//        label.numberOfLines = 0
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    var disposeBag = DisposeBag()
//    
//    let viewModel = ViewModel()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        setupUI()
//        bindLocationManager()
//        bindViewModel()
//        LocationManager.shared.requestLocation() // 위치 요청
//    }
//
//    func setupUI() {
//        view.addSubview(locationButton)
//        view.addSubview(addressLabel)
//        
//        locationButton.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//            make.height.equalTo(50)
//        }
//        
//        addressLabel.snp.makeConstraints { make in
//            make.top.equalTo(locationButton.snp.bottom).offset(20)
//            make.centerX.equalTo(locationButton.snp.centerX)
//            make.height.equalTo(50)
//        }
//
//        locationButton.addTarget(self, action: #selector(didTapLocationButton), for: .touchUpInside)
//    }
//
//    /// - 위치 관리자에게 사용자의 위도 경도 데이터 받아오는 기능
//    func bindLocationManager() {
//        // LocationManager의 coordinateSubject 구독
//        // 현재 위치 정보가 변경되면 onNext 콜백이 실행
//        // 위도 경도를 받아오고
//        // fetchRegionCode 를 호출하여, 위도 경도를 주소로 변경된 값을 가져옴
//        LocationManager.shared.coordinateSubject
//            .subscribe(onNext: { [weak self] coordinate in
//                let longitude = "\(coordinate.longitude)"
//                let latitude = "\(coordinate.latitude)"
//                self?.viewModel.fetchRegionCode(longitude: longitude, latitude: latitude)
//            })
//            .disposed(by: disposeBag)
//
//        LocationManager.shared.errorSubject
//            .subscribe(onNext: { [weak self] error in
//                self?.addressLabel.text = "오류: \(error)"
//            })
//            .disposed(by: disposeBag)
//    }
//    
//    func bindViewModel() {
//        
//        // fetchRegionCode 메소드 실행 결과가 regionCodeRelay 를 통해 값 방출임
//        // regionCodeRelay 구독하여, 주소 정보가 변경되면 addressLabel 에 표시하게 함.
//        viewModel.regionCodeRelay
//            .asDriver(onErrorJustReturn: [])
//            .map { $0.first?.addressName ?? "주소 없음" }
//            .drive(addressLabel.rx.text)
//            .disposed(by: disposeBag)
//    }
//
//    @objc func didTapLocationButton() {
//        LocationManager.shared.requestLocation()
//        let searchVC = SearchViewController()
//        searchVC.viewModel = self.viewModel // 같은 ViewModel 인스턴스를 전달
//        navigationController?.pushViewController(searchVC, animated: true)
//    }
//}
