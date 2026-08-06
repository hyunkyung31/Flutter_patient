# 환자 아이디/비밀번호 인증 (Django_DL)

환자 앱 로그인 화면이 아래 API를 호출합니다.

| 용도 | Method | Path |
|------|--------|------|
| 병원 환자 회원가입 | POST | `/api/auth/patient/signup/` |
| 아이디/비번 로그인 | POST | `/api/auth/patient/login/` |

## 가입 규칙
- **새 환자를 만들지 않음**
- `patients` 테이블에서 `patient_name` + `phone_number` Exact 일치만 허용
- 성공 시 `patients.password` 저장 + `patient_auth(provider=password)` 생성
- 아이디 미입력 시 휴대폰번호가 로그인 아이디

## Django 적용

1. `docs/django_patient_password_auth.py` 내용을 `Django_DL`에 통합
2. `config/urls.py` 에 라우트 추가:

```python
from api.views import patient_login, patient_signup  # 또는 해당 모듈

path("api/auth/patient/signup/", patient_signup),
path("api/auth/patient/login/", patient_login),
```

3. 서버 재시작 후 환자 앱에서 회원가입 → 로그인 확인

## 앱 UX
1. **병원 환자 회원가입**: 이름 + 생년월일 + 전화 + 비밀번호
2. **로그인**: 아이디/비번 **또는** 카카오
3. 카카오 최초 로그인 시에도 기존처럼 이름/전화/생년월일로 병원 환자 매칭
