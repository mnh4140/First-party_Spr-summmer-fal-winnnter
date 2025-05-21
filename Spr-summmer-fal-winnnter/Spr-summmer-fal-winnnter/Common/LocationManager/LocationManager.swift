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
    private let geocoder = CLGeocoder() // 위도/경도를 주소(도시, 구, 동) 등의 텍스트로 바꾸는 객체

    // RxSwift
    // 서브젝트로 사용한 이유: 모델 계층에서 단순 이벤트 전달만 하기 때문
    // UI - ViewModel 은 relay가 적합
    let addressSubject = PublishSubject<String>()
    let errorSubject = PublishSubject<String>()

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
            locationManager.requestLocation()
        default:
            errorSubject.onNext("위치 권한이 없습니다.")
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
        
        print(location.coordinate.latitude, location.coordinate.longitude)

        // 위도 경도를 주소로 변환
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                self.errorSubject.onNext("주소 변환 실패: \(error.localizedDescription)")
                return
            }

            if let placemark = placemarks?.first {
                let address = [
                    placemark.administrativeArea, // 경기도
                    placemark.locality,           // 광주시
                    placemark.subLocality         // 신현동
                ].compactMap { $0 }.joined(separator: " ")
                // compactMap { $0 } : nil 값 제거
                // joined(separator: " ") : 공백으로 연결된 주소 문자열 생성

                self.addressSubject.onNext(address) // 이벤트 방출
            } else {
                self.errorSubject.onNext("주소를 찾을 수 없습니다.") // 에러 방출
            }
        }
    }

    // 위치 요청 실패 시 호출됨
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 에러 메시지를 ViewModel로 전달
        errorSubject.onNext("위치 가져오기 실패: \(error.localizedDescription)") // 에러 방출
    }
}
