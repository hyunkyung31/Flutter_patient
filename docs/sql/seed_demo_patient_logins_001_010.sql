-- =========================================================
-- [데모/로컬 전용] 환자 001~010 앱 아이디·비밀번호 미리 넣기
-- ⚠️ 운영(DB)에서는 절대 쓰지 마세요.
--    - 공통/예측 가능한 비번
--    - 평문 저장 (현재 프로젝트 doctor 로그인과 같은 방식)
--    - 실제 환자 개인정보와 섞이면 안 됨
--
-- 로그인 (환자 앱):
--   아이디: p001 ~ p010   또는   휴대폰번호
--   비밀번호: pass001 ~ pass010
-- =========================================================

-- 0) 대상 확인
SELECT patient_id, patient_name, phone_number, password
FROM patients
WHERE patient_id IN (
  '001','002','003','004','005','006','007','008','009','010'
)
ORDER BY patient_id;

-- 1) patients.password (평문 데모)
UPDATE patients SET password = 'pass001' WHERE patient_id = '001';
UPDATE patients SET password = 'pass002' WHERE patient_id = '002';
UPDATE patients SET password = 'pass003' WHERE patient_id = '003';
UPDATE patients SET password = 'pass004' WHERE patient_id = '004';
UPDATE patients SET password = 'pass005' WHERE patient_id = '005';
UPDATE patients SET password = 'pass006' WHERE patient_id = '006';
UPDATE patients SET password = 'pass007' WHERE patient_id = '007';
UPDATE patients SET password = 'pass008' WHERE patient_id = '008';
UPDATE patients SET password = 'pass009' WHERE patient_id = '009';
UPDATE patients SET password = 'pass010' WHERE patient_id = '010';

-- 2) patient_auth 에 로그인 아이디 (provider=password)
--    이미 있으면 지우고 다시 넣기
DELETE FROM patient_auth
WHERE provider = 'password'
  AND patient_id IN (
    '001','002','003','004','005','006','007','008','009','010'
  );

INSERT INTO patient_auth (
  patient_id, provider, provider_user_id, email, created_at, last_login
) VALUES
  ('001', 'password', 'p001', NULL, NOW(), NULL),
  ('002', 'password', 'p002', NULL, NOW(), NULL),
  ('003', 'password', 'p003', NULL, NOW(), NULL),
  ('004', 'password', 'p004', NULL, NOW(), NULL),
  ('005', 'password', 'p005', NULL, NOW(), NULL),
  ('006', 'password', 'p006', NULL, NOW(), NULL),
  ('007', 'password', 'p007', NULL, NOW(), NULL),
  ('008', 'password', 'p008', NULL, NOW(), NULL),
  ('009', 'password', 'p009', NULL, NOW(), NULL),
  ('010', 'password', 'p010', NULL, NOW(), NULL);

-- 3) 확인
SELECT
  p.patient_id,
  p.patient_name,
  p.phone_number,
  p.password AS demo_password,
  a.provider_user_id AS login_id
FROM patients p
LEFT JOIN patient_auth a
  ON a.patient_id = p.patient_id
 AND a.provider = 'password'
WHERE p.patient_id IN (
  '001','002','003','004','005','006','007','008','009','010'
)
ORDER BY p.patient_id;

-- =========================================================
-- 로그인 치트시트
--   p001 / pass001
--   p002 / pass002
--   ...
--   p010 / pass010
--   또는 phone_number / pass00N
-- =========================================================
