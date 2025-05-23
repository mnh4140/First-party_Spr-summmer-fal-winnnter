//
//  ForecastListCellBackground.swift
//  Spr-summmer-fal-winnnter
//
//  Created by 최규현 on 5/21/25.
//

import UIKit
import SnapKit

class CellBackground: UICollectionReusableView {
    static let identifier = "ForecastListCellBackground"
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(1/2)
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
        self.backgroundColor = .clear
        self.addSubview(backgroundView)
        
        backgroundView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(10)
            $0.center.equalToSuperview()
        }
    }
}
