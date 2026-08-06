-- =========================================================
-- DEMO seed template (NO real passwords in git)
-- Copy locally, fill passwords yourself, do NOT commit filled values.
-- =========================================================

SHOW COLUMNS FROM patient_auth;

-- =========================================================
-- Password updates: run locally only
-- Example (do NOT commit real values):
--   UPDATE patients SET password = 'REPLACE_ME' WHERE patient_id = 'P-2026-001';
-- =========================================================

SELECT patient_id, patient_name, phone_number
FROM patients
WHERE patient_id LIKE 'P-2026-00%'
ORDER BY patient_id;

-- =========================================================
-- Optional short login ids via patient_auth (IDs only, no passwords)
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
('P-2026-001', 'password', 'demo001', NULL, NOW(), NULL),
('P-2026-002', 'password', 'demo002', NULL, NOW(), NULL),
('P-2026-003', 'password', 'demo003', NULL, NOW(), NULL),
('P-2026-004', 'password', 'demo004', NULL, NOW(), NULL),
('P-2026-005', 'password', 'demo005', NULL, NOW(), NULL),
('P-2026-006', 'password', 'demo006', NULL, NOW(), NULL),
('P-2026-007', 'password', 'demo007', NULL, NOW(), NULL),
('P-2026-008', 'password', 'demo008', NULL, NOW(), NULL),
('P-2026-009', 'password', 'demo009', NULL, NOW(), NULL),
('P-2026-010', 'password', 'demo010', NULL, NOW(), NULL);
*/
