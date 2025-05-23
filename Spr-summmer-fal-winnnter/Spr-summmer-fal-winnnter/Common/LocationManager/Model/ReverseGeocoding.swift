//
//  model2.swift
//  Spr-summmer-fal-winnnter
//
//  Created by NH on 5/23/25.
//

import Foundation

// MARK: - Welcome
struct RegionCodeResponse: Codable {
    let meta: Meta
    let documents: [Document]
}

// MARK: - Document
extension RegionCodeResponse {
    struct Document: Codable {
        let regionType, addressName, region1DepthName, region2DepthName: String
        let region3DepthName, region4DepthName, code: String
        let x, y: Double
        
        enum CodingKeys: String, CodingKey {
            case regionType = "region_type"
            case addressName = "address_name"
            case region1DepthName = "region_1depth_name"
            case region2DepthName = "region_2depth_name"
            case region3DepthName = "region_3depth_name"
            case region4DepthName = "region_4depth_name"
            case code, x, y
        }
    }
    
    // MARK: - Meta
    struct Meta: Codable {
        let totalCount: Int

        enum CodingKeys: String, CodingKey {
            case totalCount = "total_count"
        }
    }
}


