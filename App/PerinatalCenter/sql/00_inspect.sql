-- Только чтение. Выполнять с поисковым путём, который использует клиент.
SELECT current_database(), current_schema(), current_setting('server_encoding'),
       current_setting('TimeZone'), current_setting('transaction_isolation');
SELECT table_name,column_name,data_type,is_nullable,column_default
FROM information_schema.columns WHERE table_schema=current_schema()
AND table_name IN ('role','employee','authorizations','patient','department','chamber','transfer','audit_event')
ORDER BY table_name,ordinal_position;
SELECT conrelid::regclass,conname,pg_get_constraintdef(oid)
FROM pg_constraint WHERE connamespace=current_schema()::regnamespace ORDER BY 1,2;
SELECT tgrelid::regclass,tgname,pg_get_triggerdef(oid) FROM pg_trigger
WHERE NOT tgisinternal AND tgrelid IN (to_regclass('transfer'),to_regclass('chamber'));
SELECT role_name FROM role ORDER BY 1;
SELECT department_name FROM department ORDER BY 1;
