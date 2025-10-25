# 오름
> 한국의 산 정보를 제공하고, 등산 기록을 측정/관리하는 iOS 앱  
> [앱스토어](https://apps.apple.com/kr/app/%EC%98%A4%EB%A6%84-%EB%82%98%EC%9D%98-%EB%93%B1%EC%82%B0-%EA%B8%B0%EB%A1%9D/id6753770017)  
> 현재 버전: 1.2.0  

<br>

## 📌 프로젝트 소개
> 프로젝트 기간: 2025/09/21 ~ 2025/10/09  
> 개인 프로젝트

**오름**은 등산 기록 및 관리 앱입니다.
- Restful API를 통해 한국의 산 정보를 제공하고
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

- Tuist를 활용해 Clean Architecture 계층을 모듈화하여 의존성 관리 및 빌드 효율 향상
- MVVM-C와 Combine 기반 구조체 Input/Output 패턴으로 명확한 데이터 흐름과 반응형 프로그래밍 구현
- DI Container를 적용해 서비스/개발 환경별 Repository 주입 분리 및 테스트 용이성 확보
- Alamofire와 Router 패턴으로 API 통신 구조 표준화, NWPathMonitor로 네트워크 상태 감지, 응답 값 기반 에러 처리
- Realm을 활용한 1:N 관계형 DB 설계, 양방향 관계 설정으로 데이터 무결성 보장
- 지도 줌 레벨 기반 Grid 클러스터링으로 시각적 가독성 개선
- HealthKit을 활용해 앱 종료 중에도 데이터 수집
- 기기 크기에 따른 이미지 리사이징으로 저장 공간 절감 및 성능 향상
- Firebase Analytics와 Crashlytics로 사용자 행동 및 안정성 모니터링
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

<details>
<summary><b>등산 기록 관리</b></summary>

- Realm DB를 활용하여 등산 기록을 로컬에 저장하고 관리
- 등산 중 촬영한 사진과 후기, 별점과 측정 정보 등을 함께 저장
- 디바이스 크기에 따른 이미지 Resizing으로 저장 공간 관리
- 수정/삭제, 검색/북마크 기능 지원

</details>

<details>
<summary><b>기록 측정/통계</b></summary>

- HealthKit을 활용하여 앱이 실행 중이 아니더라도 걸음 수와 이동 거리 측정
- 실시간으로 등산 진행 상황을 확인
- 운동 시간, 휴식 시간 분석 및 걸음 수, 이동 거리 통계 정보 제공
- Charts를 활용한 시간 별 걸음 수/이동 거리 시각화

</details>

<details>
<summary><b>명산 지도</b></summary>

- MapKit을 사용하여 전국의 명산 위치를 지도에 표시
- 줌 레벨에 따른 Grid 기반 Clustering
- 현재 위치 기반으로 주변 산 탐색
- 지도에서 산을 선택하여 상세 정보 확인 가능

</details>

<details>
<summary><b>검색/산 정보 보기</b></summary>

- 전국 산 정보 검색
- 검색 결과에서 산을 선택하여 상세 페이지로 이동
- Geocoding과 기상청 API를 연결해 날씨 정보 제공
- 산 이름, 위치, 높이 등의 기본 정보 제공
- Realm DB를 통한 최근 검색어 기능 지원

</details>

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
- **책임 분리와 의존성 주입(DI/DIP)의 장점을 확실히 체감하였습니다.**  
  화재로 인해 공공데이터 API 사용에 제한이 생겼을 때, 임시 JSON 데이터를 대체 소스로 사용하며 구조의 유연함을 실감했습니다.  
  추후 API가 복구되더라도 최소한의 수정만으로 전환이 가능할 것으로 기대합니다.  
  또한 App Configuration을 통해 더미 데이터를 선택적으로 사용할 수 있도록 하여, 불필요한 DB 접근이나 API 호출을 방지하며 효율적인 개발 환경을 유지할 수 있었습니다.  

- **한정된 기간 내에 목표를 달성하였습니다.**  
  기획부터 디자인, 개발, 출시까지 개인 프로젝트로 진행하였지만, 이터레이션을 구분해 세부 목표를 설정하고 우선순위를 명확히 함으로써 계획했던 일정을 지킬 수 있었습니다.  
  출시 목표와 이후 업데이트 기능을 구분하여 설계함으로써 일정 관리와 리소스 분배의 중요성을 체감하였습니다.



### Problem
- **공공데이터 API 제한으로 인한 데이터 부족 문제가 있었습니다.**  
  다행히 JSON 데이터를 확보해 임시로 사용하였지만, 일부 필드가 누락되어 있었고 데이터 수도 부족했습니다.  
  이를 보완하기 위해 DB 스키마를 수정하고 누락된 데이터를 처리하는 로직을 추가하였습니다.  
  이 경험을 통해 **데이터 스키마 설계의 중요성과 외부 서비스 장애에 대비한 유연한 구조 설계의 필요성**을 배우게 되었습니다.



### Try
- **API 복구 이후에는 더 풍부한 데이터를 활용해 로직을 단순화하고, 제공 정보를 확장할 예정입니다.**  
- **Clean Architecture, Coordinator, DIContainer 등 이론적으로 학습했던 개념을 직접 적용해보며 많은 인사이트를 얻었습니다.**  
  앞으로도 다양한 설계 개념을 지속적으로 학습하고 적용하여, 보다 완성도 높은 구조와 코드 품질을 구현할 수 있도록 노력하겠습니다.

<br>

## 연락처

- **GitHub**: [@kyhlsd](https://github.com/kyhlsd)
- **Email**: kmyghn@gmail.com

