-- =========================================================
-- DEMO seed template (NO real passwords in git)
-- Copy locally, fill passwords yourself, do NOT commit filled values.
-- =========================================================
-- login id examples: demo001..demo010
-- password: set locally only
-- DO NOT use on production
-- =========================================================

SELECT patient_id, patient_name, phone_number
FROM patients
WHERE patient_id IN ('001','002','003','004','005','006','007','008','009','010')
ORDER BY patient_id;

-- Set passwords locally (replace REPLACE_ME):
-- UPDATE patients SET password = 'REPLACE_ME' WHERE patient_id = '001';
-- UPDATE patients SET password = 'REPLACE_ME' WHERE patient_id = '002';
-- ... repeat for 003-010

DELETE FROM patient_auth
WHERE provider = 'password'
  AND patient_id IN ('001','002','003','004','005','006','007','008','009','010');

-- Login IDs only (no passwords here)
INSERT INTO patient_auth (patient_id, provider, provider_user_id, email, created_at, last_login) VALUES
('001', 'password', 'demo001', NULL, NOW(), NULL),
('002', 'password', 'demo002', NULL, NOW(), NULL),
('003', 'password', 'demo003', NULL, NOW(), NULL),
('004', 'password', 'demo004', NULL, NOW(), NULL),
('005', 'password', 'demo005', NULL, NOW(), NULL),
('006', 'password', 'demo006', NULL, NOW(), NULL),
('007', 'password', 'demo007', NULL, NOW(), NULL),
('008', 'password', 'demo008', NULL, NOW(), NULL),
('009', 'password', 'demo009', NULL, NOW(), NULL),
('010', 'password', 'demo010', NULL, NOW(), NULL);

SELECT
  p.patient_id,
  p.patient_name,
  a.provider_user_id AS login_id
FROM patients p
LEFT JOIN patient_auth a
  ON a.patient_id = p.patient_id
 AND a.provider = 'password'
WHERE p.patient_id IN ('001','002','003','004','005','006','007','008','009','010')
ORDER BY p.patient_id;
