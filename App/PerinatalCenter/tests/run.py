"""Run with a built test driver on a dedicated, local PostgreSQL instance."""
import os
from pathlib import Path
import secrets
import subprocess
import sys
import time

SQL = Path(__file__).resolve().parents[1] / "sql"
env = os.environ.copy()
if len(sys.argv) != 2 or env.get("PGHOST") != "127.0.0.1" or not env.get("PGPORT"):
    sys.exit("Specify PGHOST=127.0.0.1, PGPORT and pass the path to the integration driver.")
driver = str(Path(sys.argv[1]).resolve())
tag = secrets.token_hex(5)
database = "pc_test_" + tag
db_role = "pc_app_" + tag
env.update(PC_SQL_ROLE=db_role, PC_SQL_SECRET=secrets.token_urlsafe(24),
           PC_TEST_SECRET=secrets.token_urlsafe(24), PGCLIENTENCODING="UTF8")
cmd = ["psql", "-X", "-v", "ON_ERROR_STOP=1", "-qAt"]

def sql(statement, *, expect=True):
    proc = subprocess.run(cmd, input=statement, env=env, text=True,
                          encoding="utf-8", capture_output=True, timeout=30)
    if (proc.returncode == 0) != expect:
        raise RuntimeError("SQL result unexpected: " + proc.stderr.replace(env["PC_SQL_SECRET"], "***").replace(env["PC_TEST_SECRET"], "***"))
    return proc.stdout.strip()

def run(mode, *args):
    subprocess.run([driver, mode, *args], env=env, check=True, timeout=90)

def verify(value, label):
    if not value:
        raise RuntimeError(label)
    print("PASS",label,flush=True)

env["PGDATABASE"] = "postgres"
sql("CREATE DATABASE " + database + " ENCODING 'UTF8' TEMPLATE template0")
env["PGDATABASE"] = database
print("Test database:",database,flush=True)
for file in ["01_create_fresh.sql","03_demo_departments.sql"]:
    sql((SQL/file).read_text(encoding="utf-8"))
sql((SQL/"06_create_db_login_template.sql").read_text(encoding="utf-8").replace("perinatal_app",db_role).replace(":= 'REPLACE_WITH_OWN_DATABASE_PASSWORD'",":= '"+env["PC_SQL_SECRET"]+"'"))
sql((SQL/"05_create_first_admin_pgadmin.sql").read_text(encoding="utf-8").replace(":= 'your-admin-login'",":= 'testadmin'").replace(":= 'REPLACE_THIS_WITH_A_LONG_UNIQUE_PASSWORD'",":= '"+env["PC_TEST_SECRET"]+"'"))
run("setup")
verify(sql("SELECT current_load FROM chamber WHERE number=101")=="0", "persisted origin counter")
verify(sql("SELECT current_load FROM chamber WHERE number=301")=="0", "persisted discharge counter")
def snapshot():
    return sql("SELECT count(*) FROM transfer; SELECT current_load FROM chamber ORDER BY id; SELECT count(*) FROM audit_event WHERE action='PATIENT_TRANSFERRED'")
before=snapshot()
sql("""CREATE FUNCTION pc_reject() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN IF NEW.action='PATIENT_TRANSFERRED' THEN RAISE EXCEPTION 'test failure'; END IF; RETURN NEW; END $$;
CREATE TRIGGER pc_reject BEFORE INSERT ON audit_event FOR EACH ROW EXECUTE FUNCTION pc_reject()""")
run("rollback","0000000000000103")
verify(before==snapshot(),"SQL failure rolled back history, counters and audit")
sql("DROP TRIGGER pc_reject ON audit_event")
# Keep the destination locked until both clients actually wait inside their transfers.
with subprocess.Popen(cmd,env=env,stdin=subprocess.PIPE,stdout=subprocess.PIPE,text=True,encoding="utf-8") as gate:
    gate.stdin.write("BEGIN; SELECT number FROM chamber WHERE number=401 FOR UPDATE;\n")
    gate.stdin.flush()
    verify(gate.stdout.readline().strip()=="401","race gate acquired")
    workers=[subprocess.Popen([driver,"race",policy],env=env) for policy in ["0000000000000102","0000000000000103"]]
    try:
        for _ in range(100):
            if sql("SELECT count(*) FROM pg_stat_activity WHERE datname=current_database() AND usename='"+db_role+"' AND wait_event_type='Lock'")=="2":
                break
            time.sleep(.05)
        else:
            raise RuntimeError("Both contenders did not reach the lock")
    finally:
        gate.stdin.write("COMMIT;\n\\q\n");gate.stdin.flush()
    verify(sorted(p.wait(timeout=15) for p in workers)==[0,3],"one confirmed transfer, one full-room response")
verify(sql("SELECT current_load FROM chamber WHERE number=401")=="1","last bed occupied exactly once")
def diagnostics():
    report=sql((SQL/"04_diagnostics.sql").read_text(encoding="utf-8")).splitlines()
    return len(report)==9 and all(line.endswith("|f") for line in report[:8])
verify(diagnostics(),"all eight stored loads match history")
run("ui")
run("offline")
migration=(SQL/"02_upgrade_existing.sql").read_text(encoding="utf-8")
sql(migration,expect=False)
sql("ALTER TABLE department DROP COLUMN kind; UPDATE chamber SET current_load=0; UPDATE authorizations SET password='fabricated-legacy' WHERE login='doctor@example.test'")
prefix="SET perinatal.migration_target='"+database+"';\n"
sql(prefix+migration,expect=False)
verify(sql("SELECT password='fabricated-legacy' FROM authorizations WHERE login='doctor@example.test'")=="t","unconfirmed legacy migration rolled back")
sql(prefix+"SET perinatal.legacy_plaintext='confirmed';\n"+migration)
sql(prefix+migration)
verify(diagnostics(),"migration repaired loads and is repeatable")
verify(sql("SELECT password=crypt('fabricated-legacy',password) FROM authorizations WHERE login='doctor@example.test'")=="t","legacy credential converted")
for _ in range(2):
    sql((SQL/"07_demo_patients.sql").read_text(encoding="utf-8"))
verify(sql("SELECT count(*) FROM audit_event WHERE action='DEMO_IMPORT'")=="2","optional sample import idempotent")
print("PASS integration suite. Isolated DB retained:",database)
