-- Необязательный демонстрационный набор СПРАВОЧНИКОВ без реальных данных пациентов.
-- Выполнять после создания схемы. Имена отделений используются в проверке выписки.
BEGIN;
INSERT INTO department(department_name,kind,chamber_capacity,chamber_capacity_disease)
VALUES ('Приёмное отделение','ward',2,1),('Родовое отделение','ward',2,1),('Послеродовое отделение','postpartum',2,1),('Операционный блок','operating',2,0)
ON CONFLICT (department_name) DO NOTHING;
INSERT INTO chamber(number,capacity,department_id,disease,current_load)
SELECT v.number,v.capacity,d.id,v.disease,0
FROM (VALUES
 ('Приёмное отделение',101,2,FALSE),('Приёмное отделение',102,1,TRUE),
 ('Родовое отделение',201,2,FALSE),('Родовое отделение',202,1,TRUE),
 ('Послеродовое отделение',301,3,FALSE),('Послеродовое отделение',302,1,TRUE),
 ('Операционный блок',401,1,FALSE),('Операционный блок',402,1,FALSE)
) AS v(dept,number,capacity,disease)
JOIN department d ON d.department_name = v.dept
ON CONFLICT(department_id,number) DO NOTHING;
COMMIT;
