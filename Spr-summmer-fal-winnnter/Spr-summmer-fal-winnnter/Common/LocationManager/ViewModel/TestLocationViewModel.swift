//
//  viemodel.swift
//  Spr-summmer-fal-winnnter
//
//  Created by NH on 5/22/25.
//

import Foundation
import RxSwift
import RxRelay

class LocationViewModel {
    var disposeBag = DisposeBag()
    
    // 최신 상태(주소)를 UI에서 항상 보여줘야 하기 때문에
    // 마지막 값을 저장하고 방출할 수 있는 BehaviorRelay로 사용
    let fetchAddressRelay = PublishRelay<[AddressData.Document]>() // 주소 정보 방출
    let regionCodeRelay = BehaviorRelay<[RegionCodeResponse.Document]>(value: []) // 위도 경도 좌표 정보 방출
    
    /// - 주소를 위도 경도 값으로 변환하는 API 호출
    /// - query 값은 검색어
    func fetchAddress(query: String) {
        var components = URLComponents(string: "https://dapi.kakao.com/v2/local/search/address")
        components?.queryItems = [
            URLQueryItem(name: "query", value: query)
        ]
        
        guard let url = components?.url else { return }
        
        //print("검색 결과 최종 요청 URL: \(url)")
        
        LocationNetworkManager.shared.fetchData(url: url)
            .subscribe(onSuccess: { [weak self] (data:AddressData) in
                //print("카카오 API 응답 : \(data.documents)")
                self?.fetchAddressRelay.accept(data.documents)
            }, onFailure: { error in
                print("에러 발생: \(error.localizedDescription)")
            }).disposed(by: disposeBag)
    }
    
    /// - 위도 경도 값을 주소로 변환
    func fetchRegionCode(longitude: String, latitude: String) {
        //print("\t🗺️ [위치 뷰 모델] ViewModel fetchRegionCode")
        var components = URLComponents(string: "https://dapi.kakao.com/v2/local/geo/coord2regioncode")
        components?.queryItems = [
            URLQueryItem(name: "x", value: longitude),
            URLQueryItem(name: "y", value: latitude)
        ]
        
        guard let url = components?.url else { return }
        
        //print("\t\t🗺️ [위치 뷰 모델] ViewModel fetchRegionCode 검색 결과 최종 요청 URL: \(url)")

        LocationNetworkManager.shared.fetchData(url: url)
            .subscribe(onSuccess: { [weak self] (data:RegionCodeResponse) in
                //print("카카오 API 응답: \(data.documents)")
                self?.regionCodeRelay.accept(data.documents)
                //print("\t\t\t🗺️ [위치 뷰 모델] ViewModel fetchRegionCode regionCodeRelay 실행")
            }, onFailure: { error in
                //print("\t\t\t🗺️ [위치 뷰 모델] ViewModel fetchRegionCode 에러 발생: \(error.localizedDescription)")
            }).disposed(by: disposeBag)
    }
}
