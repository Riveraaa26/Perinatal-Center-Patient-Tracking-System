-- PgAdmin Query Tool: заменить логин и пароль в блоке DO ниже на собственные ДО запуска.
-- Используйте ТОЛЬКО в учебной/тестовой базе. НИКОГДА не коммитьте заполненную копию файла.
DO $$
DECLARE
    v_login TEXT := 'your-admin-login';
    v_password TEXT := 'REPLACE_THIS_WITH_A_LONG_UNIQUE_PASSWORD';
    v_id INTEGER;
    v_role_id INTEGER;
BEGIN
    IF v_login = 'your-admin-login' OR v_password LIKE 'REPLACE_THIS%' OR length(v_password) < 12 OR octet_length(v_password) > 72 OR btrim(v_login)='' THEN
        RAISE EXCEPTION 'Сначала установите собственные логин и пароль (не меньше 12 символов).';
    END IF;
    SELECT id INTO v_role_id FROM role WHERE role_name='Администратор';
    IF v_role_id IS NULL THEN RAISE EXCEPTION 'Сначала выполните 01_create_fresh.sql'; END IF;
    IF EXISTS (SELECT 1 FROM authorizations WHERE login=v_login) THEN
        RAISE EXCEPTION 'Логин уже существует. Запустите скрипт с новым логином.';
    END IF;
    INSERT INTO employee(name,sour_name,role_id,block)
    VALUES ('Тестовый','Администратор',v_role_id,FALSE) RETURNING id INTO v_id;
    INSERT INTO authorizations(employee_id,login,password)
    VALUES (v_id,v_login,crypt(v_password,gen_salt('bf',12)));
END $$;
