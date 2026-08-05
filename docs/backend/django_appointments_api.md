# Appointments API (Django_DL)

최신 `main`(85d8186) 기준 예약 API 추가분입니다.

## GitHub에 올리기 (권한 있는 PC에서)

```bash
cd /path/to/Django_DL
git checkout main
git pull origin main
git checkout -b feat/appointments-api
git am django_appointments_deploy.patch
# 또는: git apply django_appointments_deploy.patch && git add -A && git commit -m "feat: add appointments API"
git push -u origin feat/appointments-api
```

그다음 GitHub에서 `main`으로 PR/머지 후 VM 배포.

## VM 배포

```bash
cd /path/to/Django_DL   # 서버上的 경로
git pull origin main    # 머지된 뒤
python manage.py migrate api
# gunicorn / systemd 재시작
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8000/api/appointments/
# 기대: 401 (인증 필요). 404면 코드 미반영.
```

파일만 복사할 때:
- `api/appointment_views.py` (신규)
- `api/migrations/0009_appointment.py` (신규)
- `api/models.py`, `api/serializers.py`, `api/views.py`, `config/urls.py` (수정)
