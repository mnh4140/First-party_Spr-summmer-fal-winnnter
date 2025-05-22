//
//  MainViewModel.swift
//  Spr-summmer-fal-winnnter
//
//  Created by NH on 5/21/25.
//

import UIKit
import Foundation
import RxSwift
import RxRelay
import SideMenu

class MainViewModel {
    
    enum Input {
        case settingButtonTap
    }
    
    struct Output {
        let showSettingMenu = PublishRelay<Void>()
    }
    
    private let disposeBag = DisposeBag()
    
    let input = PublishRelay<Input>()
    let output = Output()
    
    init() {
        transform()
        setUpSideMenuNavigationVC()
    }
    
    private func transform() {
        self.input.bind(onNext: { [weak self] input in
            guard let self else { return }
            
            switch input {
            case .settingButtonTap:
                output.showSettingMenu.accept(())
            }
        })
            .disposed(by: disposeBag)
    }
    
    func showSettingMenu(on vc: UIViewController) {
        guard let sideMenu = SideMenuManager.default.leftMenuNavigationController else { return }
        vc.present(sideMenu, animated: true)
    }
    
    private func setUpSideMenuNavigationVC() {
        let menuNavVC = SideMenuNavigationController(rootViewController: SettingsViewController())
        
        menuNavVC.menuWidth = UIScreen.main.bounds.width * 0.7
        menuNavVC.presentationStyle = .menuSlideIn
        SideMenuManager.default.leftMenuNavigationController = menuNavVC
//           SideMenuManager.default.leftMenuNavigationController?.setNavigationBarHidden(true, animated: true)
    }
}
