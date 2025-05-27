//
//  ClothesViewModel.swift
//  Spr-summmer-fal-winnnter
//
//  Created by Suzie Kim on 5/26/25.
//

import Foundation
import RxSwift
import RxCocoa

final class ClothesViewModel {
    
    // 외부에서 온도/날씨를 받아 추천 결과를 방출
    let recommendation = BehaviorRelay<OutfitRecommendation?>(value: nil)
    let message = BehaviorRelay<String>(value: "")
    
    
    // 외부에서 호출
    func update(temp: Double, condition: String, tempUnit: Int) {
        let normalizedTemp = tempUnit == 0 ? temp : fahrenheitToCelsius(temp)
        let normalizedCondition = condition.lowercased()
        let result = recommendClothes(temp: normalizedTemp, condition: normalizedCondition)
        let text = generateMessage(displayTemp: temp, tempForLogic: normalizedTemp, condition: normalizedCondition, tempUnit: tempUnit)
        recommendation.accept(result)
        message.accept(text)
    }
    
    private func fahrenheitToCelsius(_ f: Double) -> Double {
        return (f - 32) * 5 / 9
    }

    private func generateMessage(displayTemp: Double, tempForLogic: Double, condition: String, tempUnit: Int) -> String {
        let unitLabel = tempUnit == 0 ? "섭씨" : "화씨"
        let prefix = "\(unitLabel) \(Int(displayTemp))도입니다! "
            switch condition {
            case "rain":
                return prefix + "우산 챙기고 방수 옷을 입으세요 ☔️"
            case "snow":
                return prefix + "눈 오는 날엔 따뜻하게 입으세요 ❄️"
            default:
                switch tempForLogic {
                case ..<5:
                    return prefix + "매우 추우니 패딩은 필수예요 🥶"
                case 5..<15:
                    return prefix + "쌀쌀하니 겉옷을 챙기세요🧥"
                case 15..<22:
                    return prefix + "선선한 날씨예요 👌"
                case 22..<28:
                    return prefix + "가볍게 입기 좋아요 ☀️"
                default:
                    return prefix + "더우니 시원하게 입으세요 🔥"
                }
            }
        }

    private func recommendClothes(temp: Double, condition: String) -> OutfitRecommendation {
        switch condition {
        case "rain":
            return OutfitRecommendation(topImageName: "raincoat ", bottomImageName: "rainboots ")
        case "snow":
            return OutfitRecommendation(topImageName: "long jacket", bottomImageName: "boots ")
        default:
            switch temp {
            case ..<5:
                return OutfitRecommendation(topImageName: "padded coat ", bottomImageName: "sweater ")
            case 5..<15:
                return OutfitRecommendation(topImageName: "trench ", bottomImageName: "jeans ")
            case 15..<22:
                return OutfitRecommendation(topImageName: "hoodie ", bottomImageName: "jeans ")
            case 22..<28:
                return OutfitRecommendation(topImageName: "T-shirt ", bottomImageName: "shorts ")
            default:
                return OutfitRecommendation(topImageName: "sleeveless ", bottomImageName: "shorts ")
            }
        }
    }


}
