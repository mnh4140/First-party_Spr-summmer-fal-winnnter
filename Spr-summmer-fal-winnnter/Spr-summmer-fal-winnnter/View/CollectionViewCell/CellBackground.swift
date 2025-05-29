//
//  ForecastListCellBackground.swift
//  Spr-summmer-fal-winnnter
//
//  Created by 최규현 on 5/21/25.
//

import UIKit
import SnapKit

class CellBackground: UICollectionReusableView {
    static let identifier = "CellBackground"
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 121/255, green: 197/255, blue: 202/255, alpha: 1.0)
        view.layer.cornerRadius = 20
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = UIColor(red: 140/255, green: 216/255, blue: 219/255, alpha: 1.0)
        self.addSubview(backgroundView)
        
        backgroundView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.bottom.equalToSuperview()//.inset(10)
            $0.center.equalToSuperview()
        }
    }
}
