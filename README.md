# 오름
> 한국의 산 정보를 제공하고, 등산 기록을 측정/관리하는 iOS 앱  
> [앱스토어](https://apps.apple.com/kr/app/%EC%98%A4%EB%A6%84-%EB%82%98%EC%9D%98-%EB%93%B1%EC%82%B0-%EA%B8%B0%EB%A1%9D/id6753770017)  
> 현재 버전: 1.5.0  

<br>

## 📌 프로젝트 소개
> 프로젝트 기간: 2025/09/21 ~ 2025/10/09  
> 업데이트 기간: 2025/10/10 ~ 현재  
> 개인 프로젝트

**오름**은 등산 기록 및 관리 앱입니다.
- 한국의 산 정보를 제공하고
- 등산 활동을 추적해 통계를 제공하며
- 사진, 후기, 별점으로 등산 기록을 관리할 수 있습니다.

<br>

## 📌 개발 환경

- **iOS Deployment Target** : 16.0+
- **Xcode** : 16.4
- **Swift** : 6.1.2
- **개발 도구** : Tuist

<br>
  
## 📌 구현 사항  

**Architecture**
- Tuist를 활용한 Clean Architecture 계층 모듈화로 의존성 관리 및 빌드 효율 향상
- MVVM-C와 Combine 기반 구조체 Input/Output 패턴으로 명확한 데이터 흐름과 반응형 프로그래밍 구현

**Network**
- Alamofire와 Router 패턴으로 API 통신 구조 표준화, protocol을 활용한 응답 값 기반 에러 처리
- NWPathMonitor로 네트워크 상태를 감지해 단절/재연결 배너를 상단 표기

**Database**
- Realm을 활용한 1:N 관계형 DB 설계, 양방향 관계 설정으로 데이터 무결성 보장
- Index를 활용한 DB 검색 및 정렬 성능 최적화

**Caching**
- NSCache와 FileManager를 활용한 캐싱 구현으로 데이터 접근 속도 개선 및 네트워크 단절 대응
- NSCache로 메모리 캐시, FileManager로 디스크 캐시를 LRU 방식으로 구현
- 캐시 유효기간 설정으로 E-Tag 미지원 환경에서 데이터 정합성 확보
- 메모리 캐시 -> 디스크 캐시 -> 네트워크 파이프라인 구축

**HealthKit**
- HealthKit을 활용한 앱 종료 상태에서의 데이터 수집, 휴리스틱 필터와 칼만 필터로 데이터 보정
  1. iOS HealthKit의 배터리 최적화로 일부 기록이 누락되고 데이터가 일괄 업데이트 되는 문제 발견
  2. 휴리스틱 필터 기반 이상치 감지 및 균등 배분
  3. 칼만 필터 기반 보정을 통해 실제 걸음 수 / 이동 거리에 가깝게 복원
- 권한 미허용 시 설정으로 이동 유도, 앱이 Active 상태가 되었을 때 권한 확인

**Clustering**
- Quad-Tree 기반 클러스터링으로 지돚의 시각적 가독성과 효율성 개선
  1. 전체 데이터의 경계를 계산하고, Quad-Tree 생성하여, capacity 초과 시 재귀적으로 4분할하며 데이터 삽입
  2. 지도의 줌 레벨에 따라 Quad-Tree의 최대 탐색 깊이를 조정하여 확대 시 개별 마커, 축소 시 클러스터를 표시
  3. 가시 영역 검사로 필요한 노드만 조회, 실제 거리 기반 서브 클러스터링
- 지도 범위 한국으로 한정

**Widget**
- App Group과 UserDefaults를 활용하며 메인 앱과 위젯 간 측정 데이터를 공유
- 측정 상태에서 5분 간격의 Timeline Entry를 미리 생성하는 방식으로 위젯의 실시간 업데이트 한계 극복
- 측정 종료 시 새로운 정적 Timeline으로 교체하여 불필요한 리소스 소비 방지 및 배터리 효율성 최적화

**CI / CD**
- DI Container를 적용해 서비스/개발 환경별 Repository 주입 분리 및 테스트 용이성 확보
- Github Actions와 Fastlane으로 자동화된 테스트와 배포 시스템 구현

**Mornitoring**
- Firebase Analytics와 Crashlytics로 사용자 행동 및 안정성 모니터링

**etc.**
- 기기 크기 기반 이미지 리사이징으로 저장 공간 절감 및 성능 향상
- 로컬 Push 알림으로 등산 완료 시 앱에서의 측정 종료 유도
- Offset 기반 페이지네이션 중복 데이터 제거

**Frameworks**  
- UIKit(code base, +SwiftUI), Combine, MapKit, CoreLocation, HealthKit, Charts, NWPathMonitor, Tuist, Realm, Alamofire,XMLCoder, Kingfisher, SnapKit, Toast, Firebase Analytics, Firebase Crashlytics

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
    <td><img src="https://github.com/user-attachments/assets/3ab1071c-5414-4ae0-8568-7e07af5934c8" alt="등산 기록 관리"></td>
    <td><img src="https://github.com/user-attachments/assets/0c59b980-e1ca-4e7e-855c-c0155386e2f4" alt="기록 측정/통계"></td>
    <td><img src="https://github.com/user-attachments/assets/8e370234-45c3-4acd-91bb-edaf2616d867" alt="명산 지도"></td>
    <td><img src="https://github.com/user-attachments/assets/cf01e639-e6b6-4780-baa9-5a5020253dfb" alt="검색/산 정보 보기"></td>
  </tr>
</table>

**등산 기록 관리**
- 등산 기록을 사진, 후기, 별점 등으로 저장
- 등산 기록 통계 제공(산 개수, 총 등산 횟수, 총 높이)
- 기록 수정 / 삭제, 검색 및 북마크 기능


**기록 측정/통계**
- 등산 중 걸음 수와 이동 거리 측정
- 5분 단위, 평균 대비 기록 분석 및 차트로 시각화된 통계 데이터 제공
- 위젯을 통한 등산 측정 진행 상황 표기(산 이름, 측정 경과 시간)
- 로컬 Push 알림 발송으로 등산 완료 시 측정 종료 유도


**명산 지도**
- 전국 100대 명산 지도 표기
- 현재 위치 기반 산과의 거리 표기
- 산이 밀집된 지역은 그룹화하여 개수로 표기
- 산 선택 시 상세 정보 확인 가능


**검색/산 정보 보기**
- 전국 산 정보 검색으로 산 상세 정보와 해당 지역 날씨 정보 제공
- 최근 검색어 기능 지원

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
- **API 복구 이후에는 더 풍부한 데이터를 활용해 로직을 단순화하고, 제공 정보를 확장할 예정입니다. (업데이트 완료)**  
- **Clean Architecture, Coordinator, DIContainer 등 이론적으로 학습했던 개념을 직접 적용해보며 많은 인사이트를 얻었습니다.**  
  앞으로도 다양한 설계 개념을 지속적으로 학습하고 적용하여, 보다 완성도 높은 구조와 코드 품질을 구현할 수 있도록 노력하겠습니다.

<br>

## 연락처

- **GitHub**: [@kyhlsd](https://github.com/kyhlsd)
- **Email**: kmyghn@gmail.com

