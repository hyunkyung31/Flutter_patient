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

- `POST {API_BASE_URL}/auth/kakao/login`
- body: `{ "accessToken": "<kakao-access-token>" }`

If confirm succeeds but the app shows a server connection error, check `.env` `API_BASE_URL`.

## Rebuild
Manifest/scheme changes require a full rebuild:

```bash
flutter clean
flutter pub get
flutter run
```
