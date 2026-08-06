-- =========================================================
-- patients 001~010 에 휴대폰번호(고유) 채우기
-- 형식: 010XXXXXXXX (하이픈 없음, 11자리)
-- HeidiSQL / MySQL 용
-- =========================================================

-- 0) 먼저 ID 형식 확인
SELECT patient_id, patient_name, phone_number
FROM patients
ORDER BY patient_id
LIMIT 20;

-- =========================================================
-- A안) patient_id 가 '001' ~ '010' 인 경우
-- =========================================================
UPDATE patients SET phone_number = '01038471201' WHERE patient_id = '001';
UPDATE patients SET phone_number = '01059283746' WHERE patient_id = '002';
UPDATE patients SET phone_number = '01067192835' WHERE patient_id = '003';
UPDATE patients SET phone_number = '01045827391' WHERE patient_id = '004';
UPDATE patients SET phone_number = '01076384920' WHERE patient_id = '005';
UPDATE patients SET phone_number = '01082947513' WHERE patient_id = '006';
UPDATE patients SET phone_number = '01091562847' WHERE patient_id = '007';
UPDATE patients SET phone_number = '01024681937' WHERE patient_id = '008';
UPDATE patients SET phone_number = '01035719482' WHERE patient_id = '009';
UPDATE patients SET phone_number = '01046820573' WHERE patient_id = '010';

-- =========================================================
-- B안) patient_id 가 'P001' ~ 'P010' / 'PAT-001' 등이면
--      아래 ID만 실제 값으로 바꿔서 실행
-- =========================================================
/*
UPDATE patients SET phone_number = '01038471201' WHERE patient_id = 'P001';
UPDATE patients SET phone_number = '01059283746' WHERE patient_id = 'P002';
UPDATE patients SET phone_number = '01067192835' WHERE patient_id = 'P003';
UPDATE patients SET phone_number = '01045827391' WHERE patient_id = 'P004';
UPDATE patients SET phone_number = '01076384920' WHERE patient_id = 'P005';
UPDATE patients SET phone_number = '01082947513' WHERE patient_id = 'P006';
UPDATE patients SET phone_number = '01091562847' WHERE patient_id = 'P007';
UPDATE patients SET phone_number = '01024681937' WHERE patient_id = 'P008';
UPDATE patients SET phone_number = '01035719482' WHERE patient_id = 'P009';
UPDATE patients SET phone_number = '01046820573' WHERE patient_id = 'P010';
*/

-- =========================================================
-- C안) 정렬 상위 10명에게 일괄 부여 (ID 형식을 모를 때)
-- =========================================================
/*
CREATE TEMPORARY TABLE tmp_phone_map (
  seq INT PRIMARY KEY,
  phone_number VARCHAR(20) NOT NULL
);

INSERT INTO tmp_phone_map (seq, phone_number) VALUES
  (1,  '01038471201'),
  (2,  '01059283746'),
  (3,  '01067192835'),
  (4,  '01045827391'),
  (5,  '01076384920'),
  (6,  '01082947513'),
  (7,  '01091562847'),
  (8,  '01024681937'),
  (9,  '01035719482'),
  (10, '01046820573');

UPDATE patients p
JOIN (
  SELECT patient_id,
         ROW_NUMBER() OVER (ORDER BY patient_id) AS seq
  FROM patients
) ranked ON ranked.patient_id = p.patient_id
JOIN tmp_phone_map m ON m.seq = ranked.seq
SET p.phone_number = m.phone_number
WHERE ranked.seq BETWEEN 1 AND 10;

DROP TEMPORARY TABLE tmp_phone_map;
*/

-- =========================================================
-- 확인
-- =========================================================
SELECT patient_id, patient_name, phone_number
FROM patients
WHERE phone_number IN (
  '01038471201','01059283746','01067192835','01045827391','01076384920',
  '01082947513','01091562847','01024681937','01035719482','01046820573'
)
ORDER BY patient_id;
