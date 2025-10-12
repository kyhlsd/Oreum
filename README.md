# 오름
> 한국의 산 정보를 제공하고, 등산 기록을 측정/관리하는 iOS 앱  
> [앱스토어](https://apps.apple.com/kr/app/%EC%98%A4%EB%A6%84-%EB%82%98%EC%9D%98-%EB%93%B1%EC%82%B0-%EA%B8%B0%EB%A1%9D/id6753770017)  
> 현재 버전: 1.1.0  

<br>

## 📌 프로젝트 소개
> 프로젝트 기간: 2025/09/21 ~ 2025/10/09  
> 개인 프로젝트

**오름**은 등산 기록 및 관리 앱입니다.
- Restful API, MapKit을 통해 한국의 산 정보를 제공하고 
- Healthkit을 활용하여 등산 활동을 추적하며
- Realm DB를 통해 사진, 후기 등의 기록을 관리할 수 있습니다.

<br>

## 📌 개발 환경

- **iOS Deployment Target** : 16.0+
- **Xcode** : 16.4
- **Swift** : 6.1.2
- **개발 도구** : Tuist

<br>
  
## 📌 기술스택

- Tuist + Clean Architecture를 통한 계층 분리 및 의존성 관리
- Coordinator를 통한 화면 전환 관리
- DIContainer로 Configuration에 따른 상용/dummy Repository 분기
- MVVM + Input/Output 패턴 및 Combine을 활용한 Reactive Programming
- Alamofire + Router 패턴으로 네트워크 구현, NWPathMonitor로 네트워크 감지
- Realm DB, property wrapper로 커스텀한 UserDefaultHelper로 로컬 데이터 관리
- MapKit + 줌 레벨에 따른 Grid 기반 Clustering
- HealthKit을 활용한 앱 비활성화 상태에서의 걸음 수, 이동 거리 측정 및 분석
- Firebase Analytics + Crashlytics를 통한 앱 분석 및 크래시 추적
- UIKit(code base, +SwiftUI), Combine, MapKit, CoreLocation, HealthKit, Charts, NWPathMonitor, Tuist, Realm, Alamofire, Kingfisher, SnapKit, Toast, Firebase Analytics, Firebase Crashlytics

<br>

## 📌 기능 
<table align="center">
  <tr>
    <th><code>등산 기록 관리</code></th>
    <th><code>기록 측정/통계</code></th>
    <th><code>명산 지도</code></th>
    <th><code>검색/산 정보 보기</code></th>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/1762f489-375d-4618-bab2-b3ea5321a3e4" alt="등산 기록 관리"></td>
    <td><img src="https://github.com/user-attachments/assets/2f6702ff-343e-436f-ae56-9bd441e7aa29" alt="기록 측정/통계"></td>
    <td><img src="https://github.com/user-attachments/assets/271e8ae8-a1f4-4c54-8095-c8dfd655e045" alt="명산 지도"></td>
    <td><img src="https://github.com/user-attachments/assets/983f0037-04ed-42fe-a890-b89de42ac4ea" alt="검색/산 정보 보기"></td>
  </tr>
</table>

<br>

## 📌 설치 및 실행

### 1. 프로젝트 클론
```bash
git clone https://github.com/kyhlsd/Oreum.git
cd Oreum
```

### 2. Tuist 설치
```bash
curl -Ls https://install.tuist.io | bash
```

### 3. 의존성 설치 및 프로젝트 생성
```bash
tuist install
tuist generate
```

### 4. 빌드 및 실행
- Xcode에서 타겟 디바이스 선택 후 실행 (⌘ + R)

> **참고**: Firebase 연동을 위해 `GoogleService-Info.plist`, API 사용을 위해 `Secrets/` 파일이 필요합니다.

<br>

## 📌 회고
  
### Keep
- 책임 분리 및 DI/DIP의 장점을 확실히 체감했다. 화재로 인해 공공 데이터 API 사용에 제한이 생겼고, 이를 임시 JSON 데이터로 대체하는 과정에서 수정이 매우 용이했다. 추후 API 복구 시 다시 API 데이터로 변경하는 과정도 간편하게 할 수 있을 것이다. 또한 App Configuration을 통해 더미 데이터를 사용할 수 있게 함으로 원치 않는 DB 사용이나, API 호출을 막으면서 간편하게 개발할 수 있었다.
- 기획부터 디자인, 개발과 출시까지 개인 프로젝트로 진행하기에 결코 긴 시간이 아니었지만, 목표했던 시간을 지킬 수 있어서 좋았다. 이터레이션을 구분해 세부 목표를 세웠고 이를 지키기 위해 시간과 노력을 온종일 쏟아부었다. 또한 우선순위를 정해 출시 목표와 업데이트 기능을 나누어서 구상하였다. 그 결과로 목표 기간 내 출시를 하였고 뿌듯함과 성취감을 느낄 수 있었다.

### Problem
- HealthKit을 사용하는 과정에서 처음 접하는 문제가 많았다. 특히 권한 허용에 따른 분기에서 권한을 읽어오는데, 읽기 권한만 필요한 경우에는 권한 정보를 명확히 주지 않았다. 서칭을 계속 하며 해당 사실을 알아냈고, 테스트 데이터를 불러와 읽기 권한 여부를 확인하는 방법을 적용하였다.
- 공공데이터 API에 제약이 생긴 것이 큰 문제였다. 막막하던 차에 다행히 JSON 데이터를 구할 수 있었다. 하지만 애초에 구상했던 것에 비해 데이터가 누락된 부분이 많았고 데이터 수 자체가 부족했다. 이를 만회하기 위해 DB 스키마를 수정하고 누락된 데이터를 구하기 위한 로직을 고민했다. DB 스키마의 중요성과 서버 장애에 따른 대비에 관한 교훈을 얻을 수 있었다.

### Try
- 추후 API가 복구되면 더 많은 정보를 받을 수 있고, 따라서 로직 간소화와 더 많은 정보를 추가하도록 해야겠다.
- 클린 아키텍처, 코디네이터, DIContainer 등 익숙치 않은 개념을 프로젝트에 적용해보며 장단점이나 사용법을 많이 체감할 수 있었다. 더 많은 개념들을 공부하고 이를 체화하기 위해 계속 시도하고 도전해야겠다.

<br>

## 연락처

- **GitHub**: [@kyhlsd](https://github.com/kyhlsd)
- **Email**: kmyghn@gmail.com

