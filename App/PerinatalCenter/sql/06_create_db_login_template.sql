-- ТОЛЬКО ДЛЯ ОТДЕЛЬНОЙ УЧЕБНОЙ БД.
-- Выполнить от владельца/администратора PostgreSQL в базе Perinatal.
-- Назначьте собственный секрет, НЕ коммитьте изменённую копию.
BEGIN;
DO $$
DECLARE v_password TEXT := 'REPLACE_WITH_OWN_DATABASE_PASSWORD';
BEGIN
    IF v_password LIKE 'REPLACE_%' OR length(v_password)<12 THEN
        RAISE EXCEPTION 'Укажите собственный пароль минимум 12 символов!';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='perinatal_app') THEN
        EXECUTE format('CREATE ROLE perinatal_app WITH LOGIN PASSWORD %L',v_password);
    ELSE
        RAISE NOTICE 'Роль perinatal_app уже существует; пароль не меняется.';
    END IF;
END $$;
GRANT USAGE ON SCHEMA public TO perinatal_app;
GRANT SELECT ON role, employee, authorizations, patient, department, chamber, transfer TO perinatal_app;
GRANT INSERT,UPDATE ON employee, authorizations, patient TO perinatal_app;
GRANT INSERT,UPDATE,DELETE ON department,chamber TO perinatal_app;
GRANT INSERT ON transfer,audit_event TO perinatal_app;
GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA public TO perinatal_app;
-- На реальном сервере этот подход не обеспечивает изоляцию по ролям приложения:
-- нужен отдельный серверный API и ограниченные права на уровне сервера.
COMMIT;
