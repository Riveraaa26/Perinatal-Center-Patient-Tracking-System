-- По желанию, только в новой учебной БД после 01, 03, 05. Две карты без размещения.
BEGIN;
DO $$ BEGIN
    IF (SELECT count(*) FROM employee e JOIN role r ON r.id=e.role_id
        WHERE r.role_name='Администратор' AND NOT e.block) <> 1 THEN
        RAISE EXCEPTION 'Для загрузки примера требуется один учебный администратор';
    END IF;
END $$;
WITH added AS (
    INSERT INTO patient(name,sour_name,policy,pregnancy_period,disease) VALUES
        ('Лада','Примерова','0000000000091001','37',false),
        ('Вера','Условная','0000000000091002','35',true)
    ON CONFLICT (policy) DO NOTHING RETURNING id
)
INSERT INTO audit_event(employee_id,action,target,target_id)
SELECT e.id,'DEMO_IMPORT','patient',added.id FROM added
CROSS JOIN employee e JOIN role r ON r.id=e.role_id
WHERE r.role_name='Администратор' AND NOT e.block;
COMMIT;
