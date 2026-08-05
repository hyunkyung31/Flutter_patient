-- =========================================================
-- 테스터 / 실제 환자용 patients INSERT 템플릿
-- 카카오 회원가입 매칭: patient_name + phone_number (Exact)
-- phone_number 는 하이픈 없이 010XXXXXXXX (11자리) 권장
-- =========================================================

-- 사용 전:
-- 1) 아래 이름/전화/ID 를 실제 테스터 정보로 수정
-- 2) primary_doctor_id 가 doctors 테이블에 있는지 확인 (예: DOC-001)
-- 3) 이미 같은 patient_id / phone 이 있으면 건너뛰거나 UPDATE

-- ----- 테스터 1 -----
INSERT INTO patients (
  patient_id, primary_doctor_id, phone_number, dataset_patient_id,
  patient_name, gender, age, history_score, ecg_result,
  risk_factors_count, troponin_t_level, underlying_diseases,
  chief_complaint, created_at
) VALUES (
  'P-2026-TEST01',
  'DOC-001',
  '01012345678',          -- ★ 테스터 실번호로 변경
  'TEST_01',
  '홍길동',                 -- ★ 앱 회원가입에 입력할 이름과 동일
  'M',
  40,
  1,
  'Nonspecific',
  1,
  0.010,
  '[]',
  '테스터 계정',
  NOW()
)
ON DUPLICATE KEY UPDATE
  phone_number = VALUES(phone_number),
  patient_name = VALUES(patient_name),
  primary_doctor_id = VALUES(primary_doctor_id);

-- ----- 테스터 2 -----
INSERT INTO patients (
  patient_id, primary_doctor_id, phone_number, dataset_patient_id,
  patient_name, gender, age, history_score, ecg_result,
  risk_factors_count, troponin_t_level, underlying_diseases,
  chief_complaint, created_at
) VALUES (
  'P-2026-TEST02',
  'DOC-001',
  '01098765432',
  'TEST_02',
  '김테스트',
  'F',
  28,
  0,
  'Normal',
  0,
  0.005,
  '[]',
  '테스터 계정',
  NOW()
)
ON DUPLICATE KEY UPDATE
  phone_number = VALUES(phone_number),
  patient_name = VALUES(patient_name),
  primary_doctor_id = VALUES(primary_doctor_id);

-- ----- 확인 -----
SELECT patient_id, patient_name, phone_number, primary_doctor_id
FROM patients
WHERE patient_id IN ('P-2026-TEST01', 'P-2026-TEST02', 'P-2026-HKG');

-- ----- (선택) 카카오 연동 초기화 후 재가입 테스트 -----
-- DELETE FROM patient_auth WHERE provider = 'kakao' AND patient_id = 'P-2026-TEST01';
