-- Проверка текущей занятости и расхождений в chamber.current_load (только чтение).
WITH last_event AS (
    SELECT DISTINCT ON (patient_id) patient_id, chamber_id
    FROM transfer ORDER BY patient_id,id DESC
), actual AS (
    SELECT chamber_id,COUNT(*)::integer AS count_patients
    FROM last_event WHERE chamber_id IS NOT NULL GROUP BY chamber_id
)
SELECT d.department_name,c.number,c.capacity,c.current_load,
       COALESCE(a.count_patients,0) AS calculated_load,
       c.capacity-COALESCE(a.count_patients,0) AS free_places,
       (c.current_load <> COALESCE(a.count_patients,0)) AS mismatch
FROM chamber c JOIN department d ON d.id=c.department_id
LEFT JOIN actual a ON a.chamber_id=c.id
ORDER BY d.department_name,c.number;

-- Сколько пациенток с незавершённым пребыванием и сколько выписанных:
WITH last_event AS (
    SELECT DISTINCT ON (patient_id) patient_id,id,chamber_id
    FROM transfer ORDER BY patient_id,id DESC
)
SELECT (SELECT count(*) FROM patient) AS total_patients,
       count(*) FILTER(WHERE chamber_id IS NOT NULL) AS in_chambers,
       count(*) FILTER(WHERE chamber_id IS NULL) AS discharged
FROM last_event;
