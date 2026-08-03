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
- Debug/release key hash

Register the Android debug/release key hash in Kakao Developers Console.
(If needed, generate the debug key hash with `keytool` as in the Kakao docs.)

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
