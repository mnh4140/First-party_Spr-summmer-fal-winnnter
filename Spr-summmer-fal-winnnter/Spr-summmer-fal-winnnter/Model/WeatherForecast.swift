//
//  WeatherForecast.swift
//  Spr-summmer-fal-winnnter
//
//  Created by 허성필 on 5/21/25.
//

import Foundation

// MARK: - WeatherForecast
struct WeatherForecast: Codable, Hashable {
    let cod: String // 요청 결과 코드
    let message, cnt: Int // 메시지 (대부분 0), 예보 개수
    let list: [ForecastList] // 예보 목록 (3시간 간격 데이터)
    let city: ForecastCity // 도시 정보
}

// MARK: - City
struct ForecastCity: Codable, Hashable {
    let id: Int // 도시 ID
    let name: String // 도시 이름 (예: "Seoul")
    let coord: ForecastCoord // 위도와 경도 정보
    let country: String  // 국가 코드
    let population, timezone, sunrise, sunset: Int // 인구수, UTC 기준 시간대, 일출 시간, 일몰 시간 (유닉스 타임스탬프)
}

// MARK: - Coord
struct ForecastCoord: Codable, Hashable {
    let lat, lon: Double // 위도, 경도
}

// MARK: - List
struct ForecastList: Codable, Hashable {
    let dt: Int // 데이터 시각 (유닉스 타임스탬프)
    let main: MainClass // 기온 등 주요 정보
    let weather: [ForecastWeather] // 날씨 정보 배열
    let clouds: ForecastClouds // 구름 정보
    let wind: ForecastWind // 바람 정보
    let visibility: Int? // 가시 거리 (미터 옵셔널)
    let pop: Double // 강수 확률 (0.0 ~ 1.0)
    let rain: Rain? // 강우량 정보 (옵셔널)
    let sys: ForecastSys // 일/밤 구분
    let dtTxt: String // 날짜/시간 (예: "2025-05-20 12:00:00")

    enum CodingKeys: String, CodingKey {
        case dt, main, weather, clouds, wind, visibility, pop, rain, sys
        case dtTxt = "dt_txt"
    }
}

// MARK: - Clouds
struct ForecastClouds: Codable, Hashable {
    let all: Int // 구름 양 (%)
}

// MARK: - MainClass
struct MainClass: Codable, Hashable {
    let temp, feelsLike, tempMin, tempMax: Double
    let pressure, seaLevel, grndLevel, humidity: Int
    let tempKf: Double

    enum CodingKeys: String, CodingKey {
        case temp // 현재 온도
        case feelsLike = "feels_like" // 체감 온도
        case tempMin = "temp_min" // 최저 온도
        case tempMax = "temp_max" // 최고 온도
        case pressure // 기압 (hPa)
        case seaLevel = "sea_level" // 해수면 기준 기압
        case grndLevel = "grnd_level" // 지면 기준 기압
        case humidity // 습도 (%)
        case tempKf = "temp_kf" // 온도 보정값
    }
}

// MARK: - Rain
struct Rain: Codable, Hashable {
    let the3H: Double // 3시간 동안의 강수량 mm

    enum CodingKeys: String, CodingKey {
        case the3H = "3h" // 키가 3h로 시작해서 the3H로 매핑
    }
}

// MARK: - Sys
struct ForecastSys: Codable, Hashable {
    let pod: Pod // 낮 / 밤 정보
}

enum Pod: String, Codable {
    case d = "d" // 낮
    case n = "n" // 밤
}

// MARK: - Weather
struct ForecastWeather: Codable, Hashable {
    let id: Int // 날씨 상태
    let main: MainEnum // 날씨 주 분류 (예 : Clear, Rain등)
    let description, icon: String // 날씨 설명, 날씨 아이콘
}

enum MainEnum: String, Codable {
    case clear = "Clear" // 맑음
    case clouds = "Clouds" // 구름낀 (흐림)
    case rain = "Rain" // 비
}

// MARK: - Wind
struct ForecastWind: Codable, Hashable {
    let speed: Double // 풍속 (m/s)
    let deg: Int // 풍향 (도)
    let gust: Double // 돌풍 속도 (m/s)
}
