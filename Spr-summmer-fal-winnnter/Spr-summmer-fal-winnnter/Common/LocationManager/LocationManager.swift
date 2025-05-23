//
//  LocationManager.swift
//  Spr-summmer-fal-winnnter
//
//  Created by NH on 5/21/25.
//

import Foundation
import CoreLocation
import RxSwift

final class LocationManager: NSObject {
    /// 위치 서비스 관리자 싱글톤 객체
    static let shared = LocationManager()

    private let locationManager = CLLocationManager() // CoreLocation의 핵심 객체. 위치를 요청하고 수신함.
     let geocoder = CLGeocoder() // 위도/경도를 주소(도시, 구, 동) 등의 텍스트로 바꾸는 객체

    // RxSwift
    // 서브젝트로 사용한 이유: 모델 계층에서 단순 이벤트 전달만 하기 때문
    // UI - ViewModel 은 relay가 적합
    let errorSubject = PublishSubject<String>()
    
    // 좌표 전달 서브젝트
    let coordinateSubject = PublishSubject<CLLocationCoordinate2D>()

    private override init() {
        super.init()
        locationManager.delegate = self // 위치가 업데이트되면 이 클래스가 콜백 받도록 설정
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // 위치 정밀도 설정 (가장 정확한 값)
    }

    /// 위치 권한 요청 메서드
    func requestLocation() {
        let status = locationManager.authorizationStatus // 현재 권한 상태 확인
        switch status {
        case .notDetermined: // 아직 사용자에게 권한을 요청하지 않은 상태 → 권한 요청
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways: // 권한이 있으면 requestLocation() 호출 → 현재 위치 1회 요청
            locationManager.requestLocation() // 한번 요청
            //locationManager.startUpdatingLocation() // 지속적 요청
            
        default:
            errorSubject.onNext("위치 권한이 없습니다.")
        }
    }
    
    /// 검색 키워드를 위도 경도로 변경하는  함수
    func findAddress(address: String) {
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print("지오코딩 실패: \(error)")
                return
            }
            
            if let location = placemarks?.first?.location {
                print("위도: \(location.coordinate.latitude), 경도: \(location.coordinate.longitude)")
            }
        }
    }
    
    func latlogToAddress(location: CLLocation) {
        // 위도 경도를 주소로 변환
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                self.errorSubject.onNext("주소 변환 실패: \(error.localizedDescription)")
                return
            }
            
            let coordinate = location.coordinate
            self.coordinateSubject.onNext(coordinate)
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    /// 위치 업데이트를 받는 delegate 메서드
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // locations.first 사용 이유 : 가장 최신 위치 하나만 사용
        guard let location = locations.first else {
            errorSubject.onNext("위치 정보를 찾을 수 없습니다.")
            return
        }
        
        // 디버깅
        print(location.coordinate.latitude, location.coordinate.longitude)

        latlogToAddress(location: location)
    }

    // 위치 요청 실패 시 호출됨
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 에러 메시지를 ViewModel로 전달
        errorSubject.onNext("위치 가져오기 실패: \(error.localizedDescription)") // 에러 방출
    }
}
