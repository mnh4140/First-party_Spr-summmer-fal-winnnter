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
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byClipping               // 줄임표 없이 잘라내지 않음
        label.adjustsFontSizeToFitWidth = true          // 필요 시 글자 크기 줄임
        label.minimumScaleFactor = 0.7                  // 최소 70%까지 줄이기 허용
        return label
    }()
    
    private let labelStackView: UIStackView = {
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 60
        return stack
    }()
    
    private let topLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    
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
    
    func imageLoad(leftImage: UIImage, rightImage: UIImage) {
        leftImageView.image = leftImage
        rightImageView.image = rightImage
    }
    
    func configure(with recommendation: OutfitRecommendation, message: String) {
        leftImageView.image = UIImage(named: recommendation.topImageName)
        rightImageView.image = UIImage(named: recommendation.bottomImageName)

        topLabel.text = "\(recommendation.topImageName)"
        bottomLabel.text = "\(recommendation.bottomImageName)"
        topLabel.textColor = .white
        bottomLabel.textColor = .white
        
        messageLabel.text = message

    }


    private func setupUI() {
        [leftImageView, rightImageView].forEach { stackView.addArrangedSubview($0) }
        
        // 라벨도 수평 스택 구성
        [topLabel, bottomLabel].forEach { labelStackView.addArrangedSubview($0) }

        // 수직 스택에 메세지 + 이미지 스택 + 라벨 스택 추가
        verticalStack.addArrangedSubview(messageLabel)
        verticalStack.addArrangedSubview(stackView)
        verticalStack.addArrangedSubview(labelStackView)

        contentView.addSubview(verticalStack)

        leftImageView.snp.makeConstraints {
            $0.width.height.equalTo(100)
        }

        rightImageView.snp.makeConstraints {
            $0.width.height.equalTo(100)
        }

        verticalStack.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

}
