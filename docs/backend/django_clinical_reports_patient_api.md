# 환자용 임상 보고서 API (Django_DL)

환자 앱 조회 순서:

1. `GET /api/emr-signoffs/me/` ← **권장**
2. `GET /api/emr-signoffs/` (환자 JWT면 본인 전달분만)
3. `GET /api/patients/{patient_id}/` 안의 `emr_signoffs` / `clinical_reports`

## 엔드포인트

### 1) 환자 me 목록

```
GET /api/emr-signoffs/me/
Authorization: Bearer <patient access>
```

- 로그인한 환자 본인 + `emr_transmitted=true` 만
- 의사 JWT → 403

응답 예:

```json
[
  {
    "id": 12,
    "patient_id": "P-2026-001",
    "doctor_id": "DOC-001",
    "doctor_name": "김순환",
    "department": "순환기내과",
    "final_result": "stenosis",
    "ai_summary": "...",
    "xai_explanation": "...",
    "report_ready": true,
    "emr_transmitted": true,
    "report_url": "http://.../api/emr-signoffs/12/report/",
    "report_generated_at": "2026-08-06T06:27:00Z",
    "transmitted_at": "2026-08-06T06:28:00Z"
  }
]
```

### 2) 전달 API (의사)

```
POST /api/emr-signoffs/{id}/transmit/
```

- `emr_transmitted=true`, `transmitted_at` 설정
- 전달 시 의사 알림 `clinical_report_ready` 생성

### 3) PDF

```
GET /api/emr-signoffs/{id}/report/
Accept: application/pdf
```

- 작성 의사, 또는 `emr_transmitted=true` 인 해당 환자 JWT만 허용
- POST(보고서 생성)는 의사만

## GitHub / 배포

변경 파일 (`Django_DL`):

- `api/views.py` — `emr_signoff_me`, 환자 스코프 list/detail/PDF, patient_detail nested
- `api/serializers.py` — `doctor_name`, `department`
- `config/urls.py` — `api/emr-signoffs/me/`

```bash
cd /path/to/Django_DL
git checkout main
git pull origin main
# feat/emr-signoffs-patient-me 브랜치 머지 후
# gunicorn / systemd 재시작
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8000/api/emr-signoffs/me/
# 기대: 401 (인증 필요). 404면 코드 미반영.
```

마이그레이션 없음.
