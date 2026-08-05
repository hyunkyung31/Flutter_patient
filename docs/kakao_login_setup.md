# Kakao Login Android Setup

## Secrets
Never commit the Kakao native app key.
Store it only in gitignored local files:

- `.env` → `KAKAO_NATIVE_APP_KEY=YOUR_NATIVE_APP_KEY`
- or `android/local.properties` → `kakao.native.app.key=YOUR_NATIVE_APP_KEY`

## Local Flutter env
```bash
cp .env.example .env
# then replace YOUR_NATIVE_APP_KEY / API_BASE_URL
```

## AndroidManifest
SDK v2 redirect activity:

- `com.kakao.sdk.flutter.auth.AuthCodeHandlerActivity`
- intent-filter host=`oauth`
- scheme injected at build time as `kakao${KAKAO_NATIVE_APP_KEY}` via Gradle `manifestPlaceholders`

## Kakao Developers Console
Register:

- Android package name: `com.vena.patient_app`
- **모든 PC / 빌드 유형의 Key Hash** (아래 참고)

### `android keyhash validation failed` / `misconfigured`
PC마다 `~/.android/debug.keystore` 가 달라서 **디버그 Key Hash가 다릅니다.**  
한 PC에서만 되면, 다른 PC·다른 폰(다른 서명)의 해시를 콘솔에 **추가로** 등록해야 합니다.

앱 실행 후 Logcat에서 `KakaoKeyHash` 로 필터하면 해시가 출력됩니다.

#### Windows (PowerShell) — debug key hash
OpenSSL이 있으면:

```bat
keytool -exportcert -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore -storepass android -keypass android | openssl sha1 -binary | openssl base64
```

OpenSSL 없이 (Git Bash / WSL에서도 동일 가능):

```bat
keytool -exportcert -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore -storepass android -keypass android -rfc > %TEMP%\vena_cert.pem
```

그 다음 [카카오 키 해시 등록](https://developers.kakao.com/console/app) → 내 애플리케이션 → 앱 설정 → 플랫폼 → Android → **키 해시**에 추가.

Release 빌드를 쓰면 **release keystore** 해시도 따로 등록해야 합니다.

## Auto-login / Biometric
- 카카오 로그인 성공 시 토큰 + `auto_login_enabled=true` 저장
- 스플래시에서 토큰+자동로그인 있으면 홈으로 이동
- 생체인증은 기본 OFF → 로그인 직후 팝업 또는 마이페이지 → 생체인증/자동로그인 에서 ON
- 로그아웃 시 토큰만 삭제, 자동로그인/생체 **설정값은 유지**

## Backend
Flutter exchanges the Kakao access token with:

### Login
- `POST {API_BASE_URL}/api/auth/kakao/login/`
- body: `{ "accessToken": "<kakao-access-token>" }`
- existing user: `{ "access", "refresh", "is_new_user": false, ... }`
- new user: `{ "is_new_user": true, "signup_token": "..." }`
  - (권장) HTTP 200
  - 앱은 404/400 body에 `signup_token`이 있어도 신규 유저로 처리

### Signup
- `POST {API_BASE_URL}/api/auth/kakao/signup/`  ← trailing slash 필수
- body:
  ```json
  {
    "signupToken": "...",
    "name": "홍길동",
    "phone": "01012345678",
    "birthDate": "1990-01-01"
  }
  ```
- 앱이 phone에서 숫자만 추출하고, birthDate를 `YYYY-MM-DD`로 정규화함
- 환자 매칭은 서버 DB의 `patient_name` + `phone_number` 기준

If confirm succeeds but the app shows a server connection error, check `.env` `API_BASE_URL`.
If it shows 404, confirm the Django routes are exactly:
- `api/auth/kakao/login/`
- `api/auth/kakao/signup/`

Emulator tip:
- `API_BASE_URL=http://10.0.2.2:8000`

## Rebuild
Manifest/scheme changes require a full rebuild:

```bash
flutter clean
flutter pub get
flutter run
```
