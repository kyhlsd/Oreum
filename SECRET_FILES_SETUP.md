# Secret Files 설정 가이드

이 프로젝트는 Git에서 제외된 2개의 중요 파일이 필요합니다. CI/CD에서 이 파일들을 사용하려면 GitHub Secrets에 등록해야 합니다.

## 📋 필요한 Secret Files

### 1. APIInfos.swift
- **위치**: `Data/Sources/Network/Secrets/APIInfos.swift`
- **용도**: 외부 API 키 관리
- **내용**:
  - Geocoder API (vworld.kr)
  - Forecast API (kma.go.kr)
  - Mountain API (data.go.kr)
  - MountainImage URL

### 2. GoogleService-Info.plist
- **위치**: `Oreum/Resources/GoogleService-Info.plist`
- **용도**: Firebase 설정
- **출처**: Firebase Console에서 다운로드

## 🔐 GitHub Secrets 등록 방법

### Step 1: APIInfos.swift 등록

1. 터미널에서 base64 인코딩:
```bash
cd /Users/kyh/Desktop/iOS/Oreum
cat Data/Sources/Network/Secrets/APIInfos.swift | base64 | pbcopy
```

2. GitHub 저장소 → Settings → Secrets and variables → Actions
3. "New repository secret" 클릭
4. Name: `API_INFOS_SWIFT`
5. Value: 클립보드에 복사된 값 붙여넣기
6. "Add secret" 클릭

### Step 2: GoogleService-Info.plist 등록

1. 터미널에서 base64 인코딩:
```bash
cd /Users/kyh/Desktop/iOS/Oreum
cat Oreum/Resources/GoogleService-Info.plist | base64 | pbcopy
```

2. GitHub 저장소 → Settings → Secrets and variables → Actions
3. "New repository secret" 클릭
4. Name: `GOOGLE_SERVICE_INFO_PLIST`
5. Value: 클립보드에 복사된 값 붙여넣기
6. "Add secret" 클릭

## ✅ 확인 방법

Secret이 올바르게 등록되었는지 확인:

1. GitHub 저장소 → Settings → Secrets and variables → Actions
2. 다음 2개의 Secret이 보여야 함:
   - `API_INFOS_SWIFT`
   - `GOOGLE_SERVICE_INFO_PLIST`

## 🔄 CI/CD 동작 방식

GitHub Actions 워크플로우가 실행될 때:

1. **CI 워크플로우** (.github/workflows/ci.yml)
   - Secret에서 base64 디코딩
   - `Data/Sources/Network/Secrets/APIInfos.swift` 생성
   - `Oreum/Resources/GoogleService-Info.plist` 생성
   - 테스트 및 빌드 실행

2. **Deploy 워크플로우** (.github/workflows/deploy.yml)
   - Secret에서 base64 디코딩
   - `Data/Sources/Network/Secrets/APIInfos.swift` 생성
   - `Oreum/Resources/GoogleService-Info.plist` 생성
   - TestFlight 배포

## ⚠️ 주의사항

1. **로컬 파일 보호**: 이 파일들은 `.gitignore`에 포함되어 있어 Git에 커밋되지 않습니다
2. **Secret 보안**: GitHub Secrets는 암호화되어 저장되며, 로그에 출력되지 않습니다
3. **팀 공유**: 팀원들도 각자의 로컬 환경에 이 파일들이 필요합니다
4. **업데이트**: API 키나 Firebase 설정이 변경되면 로컬 파일과 GitHub Secret 모두 업데이트해야 합니다

## 🔧 트러블슈팅

### 빌드 실패: "No such file or directory"
- GitHub Secrets에 `API_INFOS_SWIFT`와 `GOOGLE_SERVICE_INFO_PLIST`가 등록되어 있는지 확인
- Secret 값이 base64로 인코딩되어 있는지 확인

### 런타임 에러: Firebase 초기화 실패
- `GOOGLE_SERVICE_INFO_PLIST` Secret의 값이 올바른지 확인
- Firebase Console에서 최신 GoogleService-Info.plist를 다시 다운로드하여 업데이트

### API 호출 실패
- `API_INFOS_SWIFT` Secret의 값이 올바른지 확인
- API 키가 만료되지 않았는지 확인

## 📚 관련 문서

- [CI/CD 설정 가이드](./CI_CD_SETUP.md)
- [GitHub Secrets 문서](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
