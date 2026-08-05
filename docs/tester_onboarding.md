# 실제 환자 / 테스터 온보딩 체크리스트

카카오 로그인을 쓰려면 **둘 다** 필요합니다.

1. **카카오 콘솔**: 앱 서명 Key Hash 등록  
2. **서버 DB**: 그 사람의 `patients` row (이름 + 전화번호 Exact 일치)

---

## A. Key Hash (기기/빌드)

### 추천 방식 (테스터용) — APK 하나만 배포
개발 PC마다 debug keystore가 달라서 해시가 갈립니다.  
**테스터에게는 한 PC에서 만든 APK를 나눠주면 Key Hash는 1개만** 등록하면 됩니다.

```bat
cd /d D:\flutter\patient_app
flutter build apk --debug
:: 결과: build\app\outputs\flutter-apk\app-debug.apk
```

1. 그 PC에서 Logcat `KakaoKeyHash` 확인 (또는 아래 keytool)
2. [카카오 개발자 콘솔](https://developers.kakao.com/console/app)
   - 앱 설정 → 플랫폼 → Android
   - 패키지명: `com.vena.patient_app`
   - **키 해시**에 추가
3. `app-debug.apk`를 테스터 폰에 설치

### 개발자 PC를 여러 대 쓰는 경우
각 PC의 debug 해시를 **모두** 콘솔에 추가합니다.

```bat
keytool -exportcert -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore -storepass android -keypass android | openssl sha1 -binary | openssl base64
```

앱 실행 후 Logcat 필터: `KakaoKeyHash`

### 확인
- 등록 전: `misconfigured` / `android keyhash validation failed`
- 등록 후: 카카오톡 로그인 창이 뜸

---

## B. DB에 환자 row 넣기

회원가입은 **새 환자를 만들지 않고**, 기존 `patients`와  
`patient_name` + `phone_number` 로 매칭합니다.

### 필수 규칙
| 필드 | 규칙 |
|------|------|
| `patient_name` | 앱에 입력하는 이름과 **완전 동일** (공백 주의) |
| `phone_number` | `010XXXXXXXX` **숫자 11자리** (하이픈 없이 저장 권장) |
| `patient_id` | 고유 ID (예: `P-2026-TEST01`) |
| `primary_doctor_id` | 담당의 (예: `DOC-001`) — 예약 자동배정에 사용 |
| `dataset_patient_id` | 더미면 `TEST_01` 등 아무 문자열 |
| `age` | NOT NULL |

### VM / DB에서 실행
파일: `docs/sql/insert_tester_patients.sql`  
테스터 이름·전화를 고친 뒤:

```bash
# 예: MySQL
mysql -u USER -p DB_NAME < insert_tester_patients.sql

# 또는 Django 서버에서
python manage.py dbshell < insert_tester_patients.sql
```

### 넣었는지 확인
```sql
SELECT patient_id, patient_name, phone_number, primary_doctor_id
FROM patients
WHERE phone_number IN ('01012345678', '01098765432');
```

---

## C. 테스터 가입·로그인 순서

1. APK 설치 (Key Hash 등록된 빌드)
2. 앱 → **카카오로 로그인**
3. 처음이면 회원가입 화면
   - 이름 = DB `patient_name`
   - 전화 = DB `phone_number` (010…)
   - 생년월일 = 아무 유효 날짜 (현재 서버는 이름+전화만 매칭)
4. 성공 → 홈
5. 이후 같은 카카오 계정은 **로그인만** 하면 됨 (다른 폰도 Key Hash만 맞으면 OK)

### 자주 나는 오류
| 메시지 | 원인 |
|--------|------|
| keyhash / misconfigured | 콘솔에 해당 빌드 해시 없음 |
| 일치하는 환자 정보가 없습니다 | DB에 이름·전화 불일치/미등록 |
| 이미 다른 카카오 계정과 연결 | 그 환자 row에 다른 kakao가 이미 연동됨 |
| signup_token 만료 | 카카오 로그인부터 다시 |

연동 초기화(재테스트)가 필요하면 DB에서:
```sql
DELETE FROM patient_auth
WHERE provider = 'kakao'
  AND patient_id = 'P-2026-TEST01';
```

---

## D. 테스터 명단 템플릿

| 이름 | 전화(010…) | patient_id | 담당의 | Key Hash 등록 APK | 가입 완료 |
|------|------------|------------|--------|-------------------|-----------|
| 황현경 | 01034346374 | P-2026-HKG | DOC-001 | ☐ | ☐ |
| (테스터1) |  | P-2026-TEST01 | DOC-001 | ☐ | ☐ |
| (테스터2) |  | P-2026-TEST02 | DOC-001 | ☐ | ☐ |

기존 샘플: `insert_doctors_and_patients.sql` 의 **황현경 / 01034346374**  
(프로덕션 DB에 이미 들어갔는지는 VM에서 SELECT로 확인)

---

## E. 오늘 바로 할 일 (추천 순서)

1. **지금 쓰는 개발 PC** keyhash → 카카오 콘솔 등록 (본인 테스트)
2. `flutter build apk` → 테스터용 APK 1개 만들기  
3. 그 APK 서명 keyhash가 콘솔에 있는지 재확인  
4. 테스터 이름/전화로 SQL INSERT 실행  
5. 테스터 폰에 APK 설치 → 카카오 가입 시험  
6. (선택) PR #16 머지 후 자동로그인/지문 포함 빌드 배포
