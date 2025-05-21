//
//  ForecastListCellBackground.swift
//  Spr-summmer-fal-winnnter
//
//  Created by 최규현 on 5/21/25.
//

import UIKit
import SnapKit

class ForecastListCellBackground: UICollectionReusableView {
    static let identifier = "ForecastListCellBackground"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .lightGray.withAlphaComponent(1/2)
        self.layer.cornerRadius = self.frame.width / 15
        
    }
}
