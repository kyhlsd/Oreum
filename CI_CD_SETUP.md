# CI/CD 설정 가이드

Oreum 프로젝트의 CI/CD 파이프라인은 fastlane과 GitHub Actions를 사용합니다.

## 📋 목차
- [구조](#구조)
- [로컬 설정](#로컬-설정)
- [GitHub Secrets 설정](#github-secrets-설정)
- [워크플로우](#워크플로우)
- [Fastlane 레인](#fastlane-레인)

## 🏗 구조

### CI 워크플로우 (`.github/workflows/ci.yml`)
- **트리거**: PR 생성/업데이트, main/develop 브랜치에 push
- **작업**:
  - 유닛 테스트 실행
  - 빌드 검증

### Deploy 워크플로우 (`.github/workflows/deploy.yml`)
- **트리거**: main 브랜치에 push, 수동 실행
- **작업**:
  - TestFlight에 자동 배포

## 🛠 로컬 설정

### 1. Ruby 설정 (rbenv 사용)
```bash
# rbenv 설치
brew install rbenv ruby-build

# rbenv 초기화 (zshrc에 추가)
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
source ~/.zshrc

# Ruby 3.2.2 설치
rbenv install 3.2.2

# 프로젝트 디렉토리에서 Ruby 버전 설정
cd /path/to/Oreum
rbenv local 3.2.2

# 버전 확인
ruby -v  # ruby 3.2.2 출력 확인
```

### 2. 의존성 설치
```bash
# 프로젝트 루트에서
bundle install
```

### 3. Fastlane 레인 실행

#### 테스트 실행
```bash
bundle exec fastlane test
```

#### 빌드 검증
```bash
bundle exec fastlane build
```

#### TestFlight 배포 (로컬)
```bash
bundle exec fastlane beta
```

## 🔐 GitHub Secrets 설정

TestFlight 자동 배포를 위해 다음 Secrets를 GitHub 저장소에 추가해야 합니다:

### 필수 Secrets

#### 1. 앱 필수 파일 (Secret Files)

**API_INFOS_SWIFT**
- APIInfos.swift 파일 내용 (base64 인코딩)
- API 키들을 포함하는 Swift 파일
- 생성 방법:
  ```bash
  cat Data/Sources/Network/Secrets/APIInfos.swift | base64
  ```

**GOOGLE_SERVICE_INFO_PLIST**
- GoogleService-Info.plist 파일 내용 (base64 인코딩)
- Firebase 설정 파일
- 생성 방법:
  ```bash
  cat Oreum/Resources/GoogleService-Info.plist | base64
  ```

#### 2. App Store Connect API Key

**APP_STORE_CONNECT_API_KEY_ID**
- App Store Connect API Key ID
- 형식: `ABCD1234EF`

**APP_STORE_CONNECT_API_ISSUER_ID**
- App Store Connect Issuer ID
- 형식: `12345678-1234-1234-1234-123456789012`

**APP_STORE_CONNECT_API_KEY**
- App Store Connect API Key 파일 내용 (base64 인코딩)
- 생성 방법:
  ```bash
  cat AuthKey_ABCD1234EF.p8 | base64
  ```

##### API Key 생성 방법:
1. [App Store Connect](https://appstoreconnect.apple.com) → Users and Access → Keys
2. "Generate API Key" 클릭
3. Key Name 입력, Access는 "Admin" 선택
4. .p8 파일 다운로드 및 Key ID, Issuer ID 저장

#### 3. 인증서 및 프로비저닝 프로파일

**BUILD_CERTIFICATE_BASE64**
- Distribution 인증서 (.p12 파일, base64 인코딩)
- 생성 방법:
  ```bash
  # Keychain에서 인증서 내보내기 (파일 이름: certificate.p12)
  cat certificate.p12 | base64
  ```

**P12_PASSWORD**
- .p12 파일 생성 시 입력한 비밀번호

**PROVISIONING_PROFILE_BASE64**
- App Store 프로비저닝 프로파일 (base64 인코딩)
- 생성 방법:
  ```bash
  cat YourProfile.mobileprovision | base64
  ```

**KEYCHAIN_PASSWORD**
- CI에서 사용할 임시 키체인 비밀번호 (임의의 문자열)
- 예: `temp_keychain_password_123`

**FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD**
- Apple ID 2단계 인증용 앱 전용 암호
- 생성: [appleid.apple.com](https://appleid.apple.com) → Security → App-Specific Passwords

### Secrets 요약

총 **10개**의 GitHub Secrets가 필요합니다:

1. **API_INFOS_SWIFT** - API 키 파일
2. **GOOGLE_SERVICE_INFO_PLIST** - Firebase 설정 파일
3. **APP_STORE_CONNECT_API_KEY_ID** - App Store Connect API Key ID
4. **APP_STORE_CONNECT_API_ISSUER_ID** - App Store Connect Issuer ID
5. **APP_STORE_CONNECT_API_KEY** - App Store Connect API Key (base64)
6. **BUILD_CERTIFICATE_BASE64** - Distribution 인증서 (base64)
7. **P12_PASSWORD** - 인증서 비밀번호
8. **PROVISIONING_PROFILE_BASE64** - 프로비저닝 프로파일 (base64)
9. **KEYCHAIN_PASSWORD** - CI 키체인 비밀번호 (임의 설정)
10. **FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD** - Apple 앱 전용 암호

### Secrets 추가 방법

1. GitHub 저장소 → Settings → Secrets and variables → Actions
2. "New repository secret" 클릭
3. 각 Secret의 Name과 Value 입력

## 🔄 워크플로우

### CI 워크플로우 (자동)

**트리거 조건:**
- Pull Request 생성/업데이트 (target: main, develop)
- main 또는 develop 브랜치에 push

**실행 내용:**
1. 테스트 실행
2. 빌드 검증
3. 테스트 결과 아티팩트 업로드

### Deploy 워크플로우 (자동/수동)

**트리거 조건:**
- main 브랜치에 push (자동)
- Actions 탭에서 수동 실행 (workflow_dispatch)

**실행 내용:**
1. Tuist로 프로젝트 생성
2. 앱 빌드
3. TestFlight 업로드

## 📱 Fastlane 레인

### `test`
- Tuist로 프로젝트 생성
- 유닛 테스트 실행 (Domain 스킴 사용)
- 코드 커버리지 측정

> **참고**: DomainTests 타겟의 테스트를 실행하기 위해 Domain 스킴을 사용합니다.

### `build`
- Tuist로 프로젝트 생성
- 앱 빌드 (코드 서명 없이)

### `beta`
- Tuist로 프로젝트 생성
- 앱 빌드 및 서명
- TestFlight 업로드

> **참고**: 빌드 번호는 `Project.swift` 파일에서 수동으로 관리합니다.
> 배포 전에 `let buildNumber = "X"` 값을 직접 변경하세요.

## 🚨 주의사항

1. **Tuist 프로젝트**: 이 프로젝트는 Tuist로 관리되므로 `.xcodeproj`와 `.xcworkspace` 파일은 `.gitignore`에 포함됩니다
2. **빌드 번호**: `Project.swift` 파일에서 수동으로 관리합니다. TestFlight 배포 전에 빌드 번호를 증가시키세요
3. **Apple ID**: `fastlane/Appfile`의 `apple_id` 값이 올바른지 확인하세요
4. **Team ID**: `Project.swift`의 `teamID`가 올바른지 확인하세요
5. **Bundle ID**: `com.kyh.Oreum`이 맞는지 확인하세요
6. **인증서**: Distribution 인증서와 App Store 프로비저닝 프로파일이 필요합니다
7. **Match 사용**: 팀에서 인증서를 공유하려면 `match` 사용을 권장합니다

## 🔧 트러블슈팅

### Ruby 버전 오류
```bash
# Ruby 버전 확인
ruby -v

# 시스템 Ruby를 사용 중이면 rbenv 다시 초기화
eval "$(rbenv init - zsh)"
ruby -v  # 3.2.2 확인

# 또는 새 터미널 창 열기
```

### 테스트 실패
```bash
# 로컬에서 테스트 실행하여 확인
bundle exec fastlane test
```

### 빌드 실패
```bash
# Tuist 캐시 삭제
tuist clean

# 프로젝트 재생성
tuist generate
```

### 코드 서명 오류
- Xcode에서 Signing & Capabilities 탭 확인
- 인증서와 프로비저닝 프로파일이 유효한지 확인
- GitHub Secrets가 올바르게 설정되었는지 확인

## 📚 참고 자료

- [Fastlane 문서](https://docs.fastlane.tools/)
- [GitHub Actions 문서](https://docs.github.com/en/actions)
- [Tuist 문서](https://docs.tuist.io/)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
