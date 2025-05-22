//
//  SearchViewController.swift
//  Spr-summmer-fal-winnnter
//
//  Created by NH on 5/21/25.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa

// MARK: - SearchViewController
class SearchViewController: UIViewController {
    
    // Property
//    private let disposeBag = DisposeBag()
//    private let viewModel = MainViewModel()
    
    // MARK: - UIProperty
    
}

// MARK: - Lifecycle
extension SearchViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let menuButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal"),
            style: .plain,
            target: nil,
            action: nil)
        menuButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = menuButton
        
//        bind()
//        inputBind()
    }
}

// MARK: - Method
extension SearchViewController {
    
//    private func bind() {
//        viewModel.output.showSettingMenu
//            .subscribe { [weak self] _ in
//                guard let self else { return }
//                self.viewModel.showSettingMenu(on: self)
//            }.disposed(by: disposeBag)
//    }
//    
//    private func inputBind() {
//        self.navigationItem.leftBarButtonItem?.rx.tap.subscribe { [weak self] _ in
//            guard let self else { return }
//            self.viewModel.input.accept(.settingButtonTap)
//        }.disposed(by: disposeBag)
//    }
    
}
