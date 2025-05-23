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
      
    let searchBar = UISearchBar()
    let tableView = UITableView()
    
    var viewModel = ViewModel()
    
    let dataRelay = BehaviorRelay<[AddressData.Document.Address]>(value: [])
    var disposeBag = DisposeBag()
    
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

        // ViewModel에 검색어 전달
        searchBar.rx.text.orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance) // 사용자가 입력을 멈춘 뒤 300ms 후에 다음 작업 실행
            .distinctUntilChanged() // 이전 텍스트와 같으면 무시
            .filter { !$0.isEmpty } // 빈 문자열은 API 요청하지 않도록 필터링
            .subscribe(onNext: { [weak self] query in
                    self?.viewModel.fetchAddress(query: query)
                }).disposed(by: disposeBag)
        
        // Relay 구독으로 결과 받기
        viewModel.fetchAddressRelay
            .asDriver(onErrorJustReturn: [])
            .map { documents in
                documents.compactMap { $0.address }
            }
            .drive(tableView.rx.items(
                cellIdentifier: String(describing: SearchResultCell.self),
                cellType: SearchResultCell.self)
            ) { row, Address, cell in
                cell.configure(data: Address)
            }.disposed(by: disposeBag)
        
    }
}
