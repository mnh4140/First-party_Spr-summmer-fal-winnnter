//
//  ClothesCell.swift
//  Spr-summmer-fal-winnnter
//
//  Created by 최규현 on 5/21/25.
//

import UIKit
import SnapKit

class ClothesCell: UICollectionViewCell {
    static let identifier = "ClothesCell"
    
    private let leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 60
        
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func test() {
        leftImageView.backgroundColor = .white
        rightImageView.backgroundColor = .white
        print("ClothesCell test Start")
    }
    
    func imageLoad(leftImage: UIImage, rightImage: UIImage) {
        leftImageView.image = leftImage
        rightImageView.image = rightImage
    }
    
    private func setupUI() {
        [leftImageView, rightImageView]
            .forEach { stackView.addArrangedSubview($0) }
        
        contentView.addSubview(stackView)
        
        leftImageView.snp.makeConstraints {
            $0.width.height.equalTo(100)
        }
        
        rightImageView.snp.makeConstraints {
            $0.width.height.equalTo(100)
        }
        
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
