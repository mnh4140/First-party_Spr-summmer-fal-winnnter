//
//  WeatherResponse.swift
//  Spr-summmer-fal-winnnter
//
//  Created by 허성필 on 5/21/25.
//

import Foundation

// MARK: - WeatherResponse
struct WeatherResponse: Codable, Hashable {
    let coord: Coord // 위도, 경도
    let weather: [Weather] // 날씨 정보
    let base: String // 날씨 데이터의 기준
    let main: Main // 주요 기상 정보
    let visibility: Int // 가시 거리 (미터)
    let wind: Wind // 바람 정보
    let clouds: Clouds // 구름 정보
    let dt: Int // 데이터 계산 시간
    let sys: Sys // 국가 및 일출/일몰 정보
    let timezone, id: Int // 시간대 오프셋
    let name: String // 도시 이름
    let cod: Int // 응답 코드 (200이면 정상 응답)
}

// MARK: - Clouds
struct Clouds: Codable, Hashable {
    let all: Int // 구름 양 (%) - 하늘의 n%가 구름으로 덮여 있음
}

// MARK: - Coord
struct Coord: Codable, Hashable {
    let lon, lat: Double // 위도, 경도
}

// MARK: - Main
struct Main: Codable, Hashable { // 날씨 상태 배열
    let temp, feelsLike, tempMin, tempMax: Double
    let pressure, humidity, seaLevel, grndLevel: Int

    enum CodingKeys: String, CodingKey {
        case temp // 현재 기온
        case feelsLike = "feels_like" //  체감 온도
        case tempMin = "temp_min" // 최저 기온
        case tempMax = "temp_max" // 최고 기온
        case pressure, humidity // pressure = 기압, humidity = 습도
        case seaLevel = "sea_level" // 해수면 기준 기압
        case grndLevel = "grnd_level" // 지면 기준 기압
    }
}

// MARK: - Sys
struct Sys: Codable, Hashable {
    let country: String // 국가 코드
    let sunrise, sunset: Int // 일출초 일몰 시간
}

// MARK: - Weather
struct Weather: Codable, Hashable {
    let id: Int // 날씨 상태 코드
    let main: String // 날씨 상태 (예: 구름, 비, 맑음 등)
    let description: String // 날씨 상세 설명
    let icon: String // 날씨 아이콘
}

// MARK: - Wind
struct Wind: Codable, Hashable {
    let speed: Double // 바람 속도 (m/s)
    let deg: Int // 풍향
    let gust: Double? // 돌풍 풍속 (m/s)
}
