//
//  viemodel.swift
//  Spr-summmer-fal-winnnter
//
//  Created by NH on 5/22/25.
//

import Foundation
import RxSwift
import RxRelay

class ViewModel {
    var disposeBag = DisposeBag()
    let regionCodeRelay = PublishRelay<[RegionCodeResponse.Document]>()
    
    func fetchAddress(query: String) -> Observable<[Document]> {
        var components = URLComponents(string: "https://dapi.kakao.com/v2/local/search/address")
        components?.queryItems = [
            URLQueryItem(name: "query", value: query)
        ]
        
        guard let url = components?.url else {
            return Observable.just([])
        }
        
        print("검색 결과 최종 요청 URL: \(url)")
        
        return NetworkManager.shared.fetchData(url: url)
            .map { (data: AddressData) in
                return data.documents
            }
            .asObservable()
    }
    
    func fetchRegionCode(longitude: String, latitude: String) {
        var components = URLComponents(string: "https://dapi.kakao.com/v2/local/geo/coord2regioncode")
        components?.queryItems = [
            URLQueryItem(name: "x", value: longitude),
            URLQueryItem(name: "y", value: latitude)
        ]
        
        guard let url = components?.url else {
            return
        }
        
        print("검색 결과 최종 요청 URL: \(url)")
        

        NetworkManager.shared.fetchData(url: url)
            .subscribe(onSuccess: { [weak self] (data:RegionCodeResponse) in
                print("카카오 API 응답: \(data.documents)")
                self?.regionCodeRelay.accept(data.documents)
            }, onFailure: { error in
                print("에러 발생: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
}
