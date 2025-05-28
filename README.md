# <img src = "https://github.com/user-attachments/assets/6c649638-5705-4dd1-bd0a-35585d036e73" width=36 height=36> 날씨 앱 - 봄여어름갈겨어울
<div align="center">
<img src = "https://github.com/user-attachments/assets/bdfb3da0-c916-49d7-b1aa-61e370b8d9c5" width=201>
<img src = "https://github.com/user-attachments/assets/60ea97ee-47d8-41aa-b771-312ecca2014a" width=201>
<img src = "https://github.com/user-attachments/assets/0ee28ed7-8cb4-4d02-a39a-93e35a20cffa" width=201>
<img src = "https://github.com/user-attachments/assets/998089cd-7c77-47fc-9aa9-06f2bed93e23" width=201>
</div>


## 📋 프로젝트 개요
### `봄여어름갈겨어울`은 날씨 앱 입니다.
<!-- <div align="center">
<img src = "https://github.com/user-attachments/assets/6c649638-5705-4dd1-bd0a-35585d036e73" width=300>
</div> -->


→ 봄, 여름, 가을, 겨울 사계절 모두를 아우르는 앱이라는 뜻을 담고 있습니다.<br>
→ 사계절의 변화무쌍한 날씨에 적합한 옷차림을 제안하는 기능을 개발했습니다. <br>
→ 단순히 날씨를 보여주는 걸 넘어서, 훨씬 실용적인 앱이 되겠다고 생각하고 개발하게 되었습니다.
- 프로젝트 명 : 봄여어름갈겨어울
- 프로젝트 기간 : 2025.05.20 ~ 2025.05.28
- 팀 명 : 👑퍼스트파티🪩

---

## 🫂 퍼스트파티 팀 소개
> **서드파티가 아닌 퍼스트파티에서 만든 앱처럼 멋지게 앱을 개발하자!** 라는 포부가 담긴 의미로<br>
> <ins>**퍼스트파티**</ins> 이라는 팀명을 사용하게 되었습니다.

|이름|명노훈|김보미|최규현|허성필|
|---|---|---|---|---|
|프로필|![image](https://github.com/user-attachments/assets/08b29c07-12eb-4d38-a784-8b4fe747eebd)|![image](https://github.com/user-attachments/assets/ffdb842c-90f0-4cb9-a5fe-31f70a5cbd96)|![image](https://github.com/user-attachments/assets/0026d15c-48e2-4cbd-be59-ece91f4f77e1)|![image](https://github.com/user-attachments/assets/eccd6587-8014-49cb-a6d0-eaffeadb8f5d)|
|<div align="center">직책</div>|<div align="center">👑 Leader</div>|<div align="center">👤 Member</div>|<div align="center">👤 Member</div>|<div align="center">👤 Member</div>|
|<div align="center">역할</div>|- 사용자 위치 정보 수집 기능 개발<br>- 카카오 API를 이용한 주소 검색 기능 개발<br>- Pull to Refresh 기능 개발|- 옷 추천 기능 개발<br>- 앱 디자인<br>- 발표 자료 디자인|- MainVC 개발<br>- ViewModel 설계<br>- View ↔ ViewModel Binding |- 네트워크 기능 개발<br>- 날씨 API 데이터 가져오는 기능 개발<br> - 섭씨 / 화씨 변경 기능 구현|
|<div align="center">Github</div>| <div align="center">[mnh4140](https://github.com/mnh4140)</div> | <div align="center"> [bomirgasm](https://github.com/bomirgasm)</div> | <div align="center">[ghnn-n](https://github.com/ghnn-n)</div>|<div align="center">[heopill](https://github.com/heopill)</div>|

---

## 🛠️ 기술 스택
- Language : Swift
- IDE : Xcode
- 버전 : iOS 16
- Architecture : MVVM
- 라이브러리 : RxSwift, SnapKit, Alamofire, CoreLocation
- UI 구현 : UIKit
- UI 디자인 : Figma
- 디자인 패턴 : Observer 패턴, Singleton 패턴, Delegate 패턴
- 형상 관리 : Github
- 스크럼 및 마일스톤 : Notion
- 커뮤니케이션 : ZEP

## 🎨 와이어 프레임
![image](https://github.com/user-attachments/assets/891a13fb-9c96-4256-9a4d-8975e8ca8a89)
---

## 📱 주요 기능
### 1. 날씨 
#### 1-1. 현재 날씨
- 사용자 위치 기반 현재 날씨 데이터 표시
#### 1-2. 3시간 예보
- 3시간 단위의 기온과 날씨 표시
#### 1-3. 5일간 날씨
- 5일간의 하루 단위 최저, 최고 기온과 날씨, 강수량을 표시
### 2. 옷 추천
- 현재 날씨 데이터를 기반으로 어울리는 옷 추천 (예: 더운 날씨에는 반팔 반바지)
  - 비와 눈 예보을 먼저 확인 후 옷 추천
  - 각 온도에 맞는 옷차림 16가지 추천
### 3. 주소 검색 기능
- 검색 화면에서 주소를 검색기능
- 검색한 주소를 선택 시, 사용자의 위치가 선택한 주소로 변경
- 주소가 변경되면서, 변경된 주소의 날씨 데이터를 보여줌
### 4. 섭씨, 화씨 변경 기능
- 설정 화면에서 섭씨, 화씨 변경 가능
### 5. Pull to Refresh 기능
- 화면을 위로 잡아 당기면, 날씨 데이터가 새로고치 됨
---
## 📁 디렉터리 구조
```
## 디렉터리 구조

Spr-summmer-fal-winnnter
├── App
│ ├── AppDelegate.swift
│ └── SceneDelegate.swift
│
├── Common
│ ├── LocationManager
│ │ ├── Model
│ │ │ ├── ForwardGeocoding.swift
│ │ │ ├── ReverseGeocoding.swift
│ │ │ ├── LocationManager.swift
│ │ │ └── LocationNetworkManager.swift
│ │
│ ├── NetworkManager
│ │ └── NetworkManager.swift
│
├── Model
│ ├── CustomForecastList.swift
│ ├── OutfitRecommendation.swift
│ ├── WeatherForecast.swift
│ └── WeatherResponse.swift
│
├── View
│ ├── CollectionViewCell
│ │ ├── CellBackground.swift
│ │ ├── ClothesCell.swift
│ │ ├── ForecastListCell.swift
│ │ ├── MainCell.swift
│ │ ├── TempProgressBar.swift
│ │ └── TenDayForecastCell.swift
│ │
│ ├── Main
│ │ └── MainViewController.swift
│ │
│ ├── Search
│ │ ├── SearchResultCell.swift
│ │ └── SearchViewController.swift
│ │
│ └── Settings
│ └── SettingsViewController.swift
│
├── ViewModel
│ ├── Clothes
│ │ └── ClothesViewModel.swift
│ │
│ ├── Location
│ │ └── LocationViewModel.swift
│ │
│ └── Main
│ └── MainViewModel.swift
```
---
## 📋 커밋 컨벤션 (PR 시 동일하게 적용)
- Commit Message 규칙
  - 💡 [Issue 종류] #Issue 번호 - 한 줄 정리
    - 예시) [Feat] #22 - 탭바 추가

---

## 📌 브렌치 룰 & 전략
- 브랜치 전략
    - github flow를 따르되, main과 개인 작업 브랜치 사이에 Develop를 만들어서 좀 더 안전하게 공동작업을 보호.
        - main: Develop 브랜치에서 하나의 Issue에 생성된 브랜치가 안전하게 머지 되었을 때 푸시
        - Develop: 새로운 Issue가 완료되었을 때 푸시 앤 머지
        - Issue 할당 브랜치: 개인 작업용
        
- 브랜치 룰
    - **`Block force pushes` : Force push 방지**
        
- 브랜치 네이밍
    - 이슈 종류/#이슈 번호
 
---

## 📦 설치 및 실행 방법
- 이 저장소를 클론
  ```bash
  https://github.com/mnh4140/First-party_Spr-summmer-fal-winnnter.git
  ```
- Xcode로 프로젝트 파일을 실행 후 빌드!
