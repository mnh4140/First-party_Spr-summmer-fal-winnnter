//
//  model.swift
//  Spr-summmer-fal-winnnter
//
//  Created by NH on 5/22/25.
//

import Foundation

// MARK: - AddressData
struct AddressData: Codable {
    let meta: Meta
    let documents: [Document]
}

extension AddressData {
    // MARK: - Meta
    struct Meta: Codable {
        let totalCount, pageableCount: Int
        let isEnd: Bool

        enum CodingKeys: String, CodingKey {
            case totalCount = "total_count"
            case pageableCount = "pageable_count"
            case isEnd = "is_end"
        }
    }

    // MARK: - Document
    struct Document: Codable {
        let addressName, y, x, addressType: String
        let address: AddressData.Document.Address?
        let roadAddress: AddressData.Document.RoadAddress?
        
        enum CodingKeys: String, CodingKey {
            case addressName = "address_name"
            case y, x
            case addressType = "address_type"
            case address
            case roadAddress = "road_address"
        }
    }
}

extension AddressData.Document {
    // MARK: - Address
    struct Address: Codable {
        let addressName, region1DepthName, region2DepthName, region3DepthName: String?
        let region3DepthHName, hCode, bCode, mountainYn: String?
        let mainAddressNo, subAddressNo, x, y: String?
        
        enum CodingKeys: String, CodingKey {
            case addressName = "address_name"
            case region1DepthName = "region_1depth_name"
            case region2DepthName = "region_2depth_name"
            case region3DepthName = "region_3depth_name"
            case region3DepthHName = "region_3depth_h_name"
            case hCode = "h_code"
            case bCode = "b_code"
            case mountainYn = "mountain_yn"
            case mainAddressNo = "main_address_no"
            case subAddressNo = "sub_address_no"
            case x, y
        }
    }
    
    // MARK: - RoadAddress
    struct RoadAddress: Codable {
        let addressName, region1DepthName, region2DepthName, region3DepthName: String?
        let roadName, undergroundYn, mainBuildingNo, subBuildingNo: String?
        let buildingName, zoneNo, y, x: String?
        
        enum CodingKeys: String, CodingKey {
            case addressName = "address_name"
            case region1DepthName = "region_1depth_name"
            case region2DepthName = "region_2depth_name"
            case region3DepthName = "region_3depth_name"
            case roadName = "road_name"
            case undergroundYn = "underground_yn"
            case mainBuildingNo = "main_building_no"
            case subBuildingNo = "sub_building_no"
            case buildingName = "building_name"
            case zoneNo = "zone_no"
            case y, x
        }
    }
}
