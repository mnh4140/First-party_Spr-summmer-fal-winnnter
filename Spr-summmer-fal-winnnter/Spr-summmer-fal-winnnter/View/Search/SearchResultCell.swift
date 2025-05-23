//
//  SearchResultCell.swift
//  Spr-summmer-fal-winnnter
//
//  Created by NH on 5/22/25.
//

import UIKit

final class SearchResultCell: UITableViewCell {
    private let addressLabel = UILabel() // 주소
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        //contentView.backgroundColor = .green
        
        // 책 이름
        addressLabel.text = "주소 이름"
        addressLabel.textColor = .black
        addressLabel.font = .systemFont(ofSize: 18, weight: .medium)
        
        contentView.addSubview(addressLabel)
        
    }
    
    func setConstraints() {
        // 스택뷰
        addressLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    // 검색 결과 셀 데이터 적용 함수
    func configure(data: AddressData.Document.Address) {
        addressLabel.text = data.addressName
    }
}
