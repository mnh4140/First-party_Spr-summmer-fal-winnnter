//
//  SearchViewController.swift
//  Spr-summmer-fal-winnnter
//
//  Created by NH on 5/21/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SearchViewController: UIViewController {
    var disposeBag = DisposeBag()
    
    let searchBar = UISearchBar()
    let tableView = UITableView()
    
    var viewModel = ViewModel()
    
    let dataRelay = BehaviorRelay<[Address]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setContrants()
        bindSearchBar()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        //tableView.backgroundColor = .blue
        tableView.rowHeight = 60
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: String(describing: SearchResultCell.self))
    }
    
    private func setContrants() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func bindSearchBar() {
        searchBar.rx.text.orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance) // 사용자가 입력을 멈춘 뒤 300ms 후에 다음 작업 실행
            .distinctUntilChanged() // 이전 텍스트와 같으면 무시
            .filter { !$0.isEmpty } // 빈 문자열은 API 요청하지 않도록 필터링
        
            // 텍스트가 입력될 때마다 fetchAddress() 호출
            // flatMapLatest는 사용자가 입력을 계속 바꿀 때, 이전 네트워크 요청을 무시하고 가장 마지막 것만 유지합니다.
            .flatMapLatest { [weak self] query in
                self?.viewModel.fetchAddress(query: query) ?? .just([]) // nil 이면, 빈 배열을 하나 방출하고 끝나는 Observable을 대신 반환합니다.
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] documents in
                let roadAddresses = documents.compactMap { $0.address } // Kakao API 응답에서 .address만 추출해 배열로 만들고
                self?.dataRelay.accept(roadAddresses) // dataRelay에 저장 → 테이블 뷰가 자동 업데이트됨
            }, onError: { error in
                print("검색 에러 발생: \(error)")
            })
            .disposed(by: disposeBag)
        
        dataRelay
            // Rx 방식으로 테이블 뷰를 구성
            .bind(to: tableView.rx.items(
                cellIdentifier: String(describing: SearchResultCell.self),
                cellType: SearchResultCell.self)
            ) { row, Address, cell in
                cell.configure(data: Address)
            }
            .disposed(by: disposeBag)
    }
}
