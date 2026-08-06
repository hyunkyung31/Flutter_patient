# Flutter_doctor 예약 화면 연동 패치

이 디렉터리에는 의사 앱(`Flutter_doctor`) 예약 기능 구현물이 들어 있습니다.
Cloud Agent는 `Flutter_patient`에만 push 권한이 있어, 의사 앱 저장소에는 직접 PR을 올리지 못했습니다.

## 적용 방법 (권장)

```bash
cd /path/to/Flutter_doctor
git checkout -b cursor/feat-doctor-appointment-sync-61c8
git apply /path/to/Flutter_patient/docs/flutter_doctor_appointment.patch
# 또는
git am < /path/to/Flutter_patient/docs/flutter_doctor_appointment.patch
```

## 수동 복사

1. `features_appointment/` → `lib/features/appointment/`
2. `modified/` 의 4개 파일을 의사 앱 대응 경로에 반영
3. `appointment_model_test.dart` → `test/`

## 동작

- 홈 → **예약 환자** 탭 → `/appointments` 목록
- 오늘 신청/확정 건수를 홈 현황 카드에 표시
- 의사 액션: 확정 / 완료 / 취소 (`PATCH /api/appointments/{id}/`)
- 환자 앱과 동일 Django Appointment API 사용
