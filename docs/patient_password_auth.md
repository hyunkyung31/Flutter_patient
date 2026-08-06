# 환자 아이디/비밀번호 인증 + DB 준비

## 결론 (질문 답)

1. **전화번호 NULL이면 회원가입 불가**  
   병원 환자 확인이 `이름 + phone_number` Exact 매칭이라, `patients.phone_number`를 먼저 채워야 합니다.

2. **아이디는 필수**  
   가입 시 아이디 + 휴대폰 + 비밀번호를 모두 받습니다.  
   로그인 화면에서는 **아이디 또는 휴대폰번호** + 비밀번호로 로그인합니다.

3. **patients에 새 id 컬럼은 필요 없음**  
   - 병원 환자번호: 이미 있는 `patient_id` (예: `P-2026-HKG`)  
   - 앱 로그인 아이디: `patient_auth.provider_user_id` (`provider='password'`)에 저장  
   - 휴대폰: `patients.phone_number`  
   - 비밀번호: `patients.password`

```text
patients
  patient_id      ← 병원 내부 ID (로그인 아이디 아님)
  patient_name
  phone_number    ← ★ 가입 매칭용 (NULL이면 실패)
  password        ← 가입 시 저장

patient_auth
  provider = 'password'
  provider_user_id = 앱 아이디  ← ★ 여기가 로그인 아이디
  patient_id → patients
```

---

## DB에 전화번호 넣기 (필수)

HeidiSQL에서 테스터/본인 환자 row 업데이트:

```sql
-- 예: 본인
UPDATE patients
SET phone_number = '01000000000'
WHERE patient_id = 'P-2026-HKG';   -- 실제 patient_id로 변경
-- 또는
-- WHERE patient_name = '홍길동';

-- 확인
SELECT patient_id, patient_name, phone_number, primary_doctor_id
FROM patients
WHERE phone_number IS NOT NULL AND phone_number <> '';
```

템플릿: `docs/sql/insert_tester_patients.sql`

---

## Django API

| 용도 | Path |
|------|------|
| 회원가입 | `POST /api/auth/patient/signup/` |
| 로그인 | `POST /api/auth/patient/login/` |

회원가입 body:
```json
{
  "name": "홍길동",
  "phone": "01000000000",
  "birthDate": "1990-01-01",
  "username": "demo_user",
  "password": "REPLACE_ME"
}
```

로그인 body (둘 다 가능):
```json
{ "username": "demo_user", "password": "REPLACE_ME" }
```
```json
{ "username": "01000000000", "password": "REPLACE_ME" }
```

파일: `docs/django_patient_password_auth.py` → `api/patient_password_auth.py` 로 넣고 urls 연결.
