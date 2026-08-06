-- =========================================================
-- 1) patient_auth 컬럼 확인
-- =========================================================
SHOW COLUMNS FROM patient_auth;

-- =========================================================
-- 2) [추천/간단] patient_auth 없이 password 만 넣기
--    로그인 아이디 = patient_id 또는 phone_number
--    예: P-2026-001 / pass001
--        01038471201 / pass001
-- =========================================================
UPDATE patients SET password = 'pass001' WHERE patient_id = 'P-2026-001';
UPDATE patients SET password = 'pass002' WHERE patient_id = 'P-2026-002';
UPDATE patients SET password = 'pass003' WHERE patient_id = 'P-2026-003';
UPDATE patients SET password = 'pass004' WHERE patient_id = 'P-2026-004';
UPDATE patients SET password = 'pass005' WHERE patient_id = 'P-2026-005';
UPDATE patients SET password = 'pass006' WHERE patient_id = 'P-2026-006';
UPDATE patients SET password = 'pass007' WHERE patient_id = 'P-2026-007';
UPDATE patients SET password = 'pass008' WHERE patient_id = 'P-2026-008';
UPDATE patients SET password = 'pass009' WHERE patient_id = 'P-2026-009';
UPDATE patients SET password = 'pass010' WHERE patient_id = 'P-2026-010';

SELECT patient_id, patient_name, phone_number, password
FROM patients
WHERE patient_id LIKE 'P-2026-00%'
ORDER BY patient_id;

-- =========================================================
-- 3) p001 같은 짧은 아이디를 쓰려면 patient_auth 필요
--    컬럼이 없으면 아래 CREATE (없을 때만)
-- =========================================================
/*
CREATE TABLE IF NOT EXISTS patient_auth (
  auth_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  patient_id VARCHAR(50) NOT NULL,
  provider VARCHAR(20) NOT NULL,
  provider_user_id VARCHAR(100) NOT NULL,
  email VARCHAR(100) NULL,
  created_at DATETIME NOT NULL,
  last_login DATETIME NULL,
  INDEX idx_patient_auth_patient (patient_id),
  INDEX idx_patient_auth_provider (provider, provider_user_id)
);

INSERT INTO patient_auth (patient_id, provider, provider_user_id, email, created_at, last_login) VALUES
('P-2026-001', 'password', 'p001', NULL, NOW(), NULL),
('P-2026-002', 'password', 'p002', NULL, NOW(), NULL),
('P-2026-003', 'password', 'p003', NULL, NOW(), NULL),
('P-2026-004', 'password', 'p004', NULL, NOW(), NULL),
('P-2026-005', 'password', 'p005', NULL, NOW(), NULL),
('P-2026-006', 'password', 'p006', NULL, NOW(), NULL),
('P-2026-007', 'password', 'p007', NULL, NOW(), NULL),
('P-2026-008', 'password', 'p008', NULL, NOW(), NULL),
('P-2026-009', 'password', 'p009', NULL, NOW(), NULL),
('P-2026-010', 'password', 'p010', NULL, NOW(), NULL);
*/
