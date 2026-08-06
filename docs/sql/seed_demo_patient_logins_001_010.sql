-- demo seed: patients 001-010 login id/password
-- login id: p001..p010
-- password: pass001..pass010
-- DO NOT use on production

SELECT patient_id, patient_name, phone_number, password
FROM patients
WHERE patient_id IN ('001','002','003','004','005','006','007','008','009','010')
ORDER BY patient_id;

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

DELETE FROM patient_auth
WHERE provider = 'password'
  AND patient_id IN ('001','002','003','004','005','006','007','008','009','010');

INSERT INTO patient_auth (patient_id, provider, provider_user_id, email, created_at, last_login) VALUES
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
WHERE p.patient_id IN ('001','002','003','004','005','006','007','008','009','010')
ORDER BY p.patient_id;
