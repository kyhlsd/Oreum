# 오름
> 한국의 산 정보를 제공하고, 등산 기록을 측정/관리하는 iOS 앱
> [앱스토어](https://apps.apple.com/kr/app/%EC%98%A4%EB%A6%84-%EB%82%98%EC%9D%98-%EB%93%B1%EC%82%B0-%EA%B8%B0%EB%A1%9D/id6753770017)
> 현재 버전: 1.1.0



## 📌 프로젝트 소개
> 프로젝트 기간: 2025/09/21 ~ 2025/10/09
> 개인 프로젝트

**오름**은 등산 기록 및 관리 앱입니다.
- Restful API, MapKit을 통해 한국의 산 정보를 제공하고 
- Healthkit을 활용하여 등산 활동을 추적하며
- Realm DB를 통해 사진, 후기 등의 기록을 관리할 수 있습니다.



## 📌 개발 환경

- **iOS Deployment Target**: 16.0+
- **Xcode**: 16.4
- **Swift**: 6.1.2
- **개발 도구**: Tuist


  
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



## 📌 설치 및 실행

### 1. 프로젝트 클론
```bash
git clone https://github.com/kyhlsd/Oreum.git
cd Oreum
```

### 2. Tuist 설치 (선택사항)
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



## 📌 회고
  
### Keep
- 기능을 구현하는데 급급하기보다 다방면으로 고려해야 하는 점들이 정말 많다는 것을 체험할 수 있었다. 많은 경우의 수들을 생각해서 코드를 작성하고, 가독성도 고려해보면서 좋은 코드의 의미를 깨닫게 되었다.
- 지난번 프로젝트를 했을 때보다 어떤 식으로 데이터를 전달하고 기능을 구현할 지 감이 빨리 잡히고  발전했음이 느껴졌다. 공부한 것들을 많인 써볼 수 있어서 만족스러웠다.

### Problem
- 길고 복잡한 코드들을 어떻게 나누고 정리할 지 몰라서 어려움이 많았다.
- MVVM 패턴으로 코드를 수정하는데 시간이 많이 소요되었다. 처음부터 MVVM 패턴을 이해하고 생각하면서 코드를 짰으면 시간이 많이 절약되었을 것 같다.

### Try
- 다른 분들이 작성한 코드를 통해 코드를 어떻게 나누는지, 어떤 구조로 코드를 짜는지 공부하자.
- 코드를 직접 짜보니 전에 생각 못했던 문제나 고려해야 하는 점들을 알 수 있었다. 경험이 중요한 것 같다. 공부한 것을 응용해서 적용하려는 연습을 하자.



## 연락처

- **GitHub**: [@kyhlsd](https://github.com/kyhlsd)
- **Email**: kmyghn@gmail.com

