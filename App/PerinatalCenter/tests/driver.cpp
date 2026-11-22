// Separate build only. Runs against a freshly created loopback test database.
#include "yadro.h"
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlExpression>
#include <QQuickStyle>
#include <QSqlQuery>
#include <QSqlError>
#include <QThread>
#include <QProcess>
#include <QDate>
#include <cstdlib>
#include <memory>

static void check(bool value, const QString &step)
{
    if (!value) { qCritical().noquote() << "FAIL" << step; std::exit(1); }
    qInfo().noquote() << "PASS" << step;
}
static void saved(const QString &result, const QString &label)
{
    check(result.isEmpty(), label + (result.isEmpty() ? "" : " / " + result));
}
static QVariantMap match(const QVariantList &list, const QString &key, const QVariant &value)
{
    for (const QVariant &entry : list)
        if (entry.toMap().value(key).toString()==value.toString()) return entry.toMap();
    return {};
}
static QVariant js(QObject *item, const QString &source)
{
    QQmlExpression expr(qmlContext(item),item,source);
    QVariant result=expr.evaluate();
    if (expr.hasError()) { qCritical() << expr.error(); std::exit(1); }
    return result;
}
int main(int argc,char **argv)
{
    QQuickStyle::setStyle("Fusion");
    QGuiApplication app(argc,argv);
    const QString database=qEnvironmentVariable("PGDATABASE");
    check(database.startsWith("pc_test_") && qEnvironmentVariable("PGHOST")=="127.0.0.1", "isolated DB target");
    Yadro db;
    saved(db.connectToDatabase("127.0.0.1",qEnvironmentVariableIntValue("PGPORT"),database,qEnvironmentVariable("PC_SQL_ROLE"),qEnvironmentVariable("PC_SQL_SECRET")), "QPSQL");
    const QString secret=qEnvironmentVariable("PC_TEST_SECRET");
    check(secret.size()>=16,"ephemeral credentials present");
    const QString mode=app.arguments().value(1);
    auto account=[](const QString &user){ return user=="testadmin" ? user : user+"@example.test"; };
    auto login=[&](const QString &user){check(db.loginUser(account(user),secret).contains('|'),"login "+user);};
    auto patient=[&](const QString &policy){return match(db.getPatients(),"policy",policy);};
    auto dept=[&](const QString &name){return match(db.getDepartments(),"name",name).value("id").toInt();};
    auto room=[&](int id,int number){return match(db.getChambersByDepartment(id),"number",number);};
    const QString first="0000000000000101", second="0000000000000102", third="0000000000000103";
    const QString today=QDate::currentDate().toString(Qt::ISODate);
    if(mode=="setup") {
        check(!db.loginUser("testadmin","").contains('|'),"blank login denied");
        check(!db.loginUser("testadmin",secret+"x").contains('|'),"wrong password denied");
        login("testadmin");
        auto role=[&](const QString &name){return match(db.getRoles(),"name",name).value("id").toInt();};
        for (auto entry : QList<QPair<QString,QString>>{{"nurse","Медсестра"},{"doctor","Врач акушер-гинеколог"},{"head","Заведующая отделением"}})
            saved(db.createEmployee("Учебный","Сотрудник",account(entry.first),secret,role(entry.second)),entry.first);
        check(db.generatePassword().size()==16,"password generation");
        check(!db.createEmployee("Другой","Сотрудник",account("nurse"),secret,role("Медсестра")).isEmpty(),"duplicate login");
        int nurse=match(db.getEmployees(),"login",account("nurse")).value("id").toInt();
        saved(db.updateEmployee(nurse,"Тестовая","Сестра",account("nurse"),{},role("Врач акушер-гинеколог")),"role changed");
        saved(db.updateEmployee(nurse,"Тестовая","Сестра",account("nurse"),{},role("Медсестра")),"role restored");
        saved(db.setEmployeeBlocked(nurse,true),"blocked");
        check(db.loginUser(account("nurse"),secret).contains("заблокирована"),"blocked login rejected");
        login("testadmin");saved(db.setEmployeeBlocked(nurse,false),"unblocked");
        login("nurse");
        check(!db.createPatient("", "Учебная",first,"38",false).isEmpty(),"required fields");
        check(!db.createPatient("Анна","Учебная","17","38",false).isEmpty(),"invalid policy");
        saved(db.createPatient("Анна","Учебная",first,"38",false),"registration UTF-8 / leading zero");
        saved(db.createPatient("Ирина","Учебная",second,"35",true),"isolation patient");
        saved(db.createPatient("Вера","Учебная",third,"38",false),"third patient");
        check(db.createPatient("Иная","Учебная",first,"38",false).contains("зарегистрирована"),"duplicate policy");
        const int id=patient(first)["id"].toInt(), sick=patient(second)["id"].toInt();
        int reception=dept("Приёмное отделение"),post=dept("Послеродовое отделение"),op=dept("Операционный блок");
        check(db.transferPatient(id,reception,101).contains("прав"),"nurse cannot transfer");
        login("doctor");
        check(db.createPatient("А","Б","0000000000000999","38",false).contains("прав"),"doctor cannot register");
        saved(db.transferPatient(id,reception,101),"first placement");
        check(patient(first)["chamber"]=="101","registry after first placement");
        check(!db.transferPatient(id,reception,101).isEmpty(),"repeat placement rejected");
        check(!db.transferPatient(sick,reception,101).isEmpty(),"isolation rule");
        saved(db.transferPatient(sick,reception,102),"isolation placement");
        saved(db.transferPatient(sick,op,402),"operating room accepts isolation patient");
        check(patient(second)["status"]=="В операционной","operating status");
        saved(db.transferPatient(id,post,301),"cross-department transfer");
        check(patient(first)["department"]=="Послеродовое отделение" && patient(first)["chamber"]=="301","registry after transfer");
        check(room(reception,101)["free_places"].toInt()==2 && db.getPatientsByChamber(reception,101).isEmpty(),"origin released");
        check(db.getPatientsByChamber(post,301).size()==1,"destination roster");
        check(match(db.getOccupancyStatistics(),"id",post)["occupied"].toInt()==1,"occupancy statistics");
        check(db.dischargePatient(id,"Учебные рекомендации",today).contains("прав"),"doctor cannot discharge");
        login("head");
        check(!db.dischargePatient(sick,"Тест",today).isEmpty(),"postpartum prerequisite");
        check(!db.dischargePatient(id,"","2000-01-01").isEmpty(),"invalid discharge");
        saved(db.dischargePatient(id,"Учебные рекомендации",today),"discharge");
        check(patient(first)["discharged"].toBool() && room(post,301)["free_places"].toInt()==3,"closed chart and bed released");
        check(!db.dischargePatient(id,"Тест",today).isEmpty() && !db.transferPatient(id,op,401).isEmpty(),"closed chart read-only");
        auto history=db.getPatientHistory(id);
        check(history.size()==3 && history.first().toMap()["recommendations"]=="Учебные рекомендации","history retained");
        saved(db.transferPatient(sick,reception,102),"operating room released");
        check(db.transferPatient(sick,op,402,0).contains("изменено"),"stale transfer confirmation rejected");
        Yadro actor;
        check(actor.loginUser("testadmin",secret).contains('|'),"parallel admin session");
        auto headId=match(actor.getEmployees(),"login",account("head"))["id"].toInt();
        saved(actor.setEmployeeBlocked(headId,true),"revoke active session");
        check(!db.createPatient("Тест","Тест","0000000000000122","30",false).isEmpty() && db.getPatients().isEmpty(),"revoked session cannot read or write");
        saved(actor.setEmployeeBlocked(headId,false),"restore head");
    } else if(mode=="move-isolation") {
        login("head");
        saved(db.transferPatient(patient(second)["id"].toInt(),dept("Послеродовое отделение"),302),"other employee updates isolation bed");
    } else if(mode=="race" || mode=="rollback") {
        login("doctor");
        const int id=patient(app.arguments().value(2))["id"].toInt();
        const QString result=db.transferPatient(id,dept("Операционный блок"),401);
        if(mode=="rollback") check(result.contains("аудита"),"simulated audit failure");
        else if(result.isEmpty()) return 0;
        else if(result.contains("свободных мест")) return 3;
        else {qCritical()<<result; return 1;}
    } else if(mode=="ui") {
        QQmlApplicationEngine engine;
        engine.rootContext()->setContextProperty("testPasswordValue",secret);
        engine.loadFromModule("PerinatalCenter","Main");
        check(!engine.rootObjects().isEmpty(),"main window");
        QObject *window=engine.rootObjects().first();
        auto current=[&](){return js(window,"stackView.currentItem").value<QObject*>();};
        auto pause=[&](){ for(int i=0;i<45;++i){app.processEvents(); QThread::msleep(10);} };
        auto *service=engine.singletonInstance<Yadro*>("PerinatalCenter","Yadro");
        check(service!=nullptr,"QML singleton");
        for (const QString &user:QStringList{"testadmin","nurse","doctor","head"}) {
            auto *page=current();
            js(page,"loginField.text='"+account(user)+"'");
            // Supply the test secret through context, never put it in source or logs.
            js(page,"passwordField.text=testPasswordValue; loginButton.clicked()");
            pause();
            auto *workspace=current();
            check(workspace!=page,"QML login route "+user);
            if(user=="testadmin"){
                check(js(workspace,"employeeModel.count").toInt()==4,"admin employee table");
                js(workspace,"newEmployeeButton.clicked()");
                check(js(workspace,"createPassword.text.length").toInt()==16,"QML generated password");
                js(workspace,"createName.text='Тестовая'; createSourName.text='Учебная'; createLogin.text='extra@example.test'; createRoleCombo.currentIndex=rolesList.findIndex(r=>r.name==='Медсестра');saveEmployeeButton.clicked()");
                check(js(workspace,"employeeModel.count").toInt()==5 && js(workspace,"noticeText.text.includes('Пароль')").toBool(),"QML employee creation and confirmation");
                js(workspace,"notice.close()");
            }else{
                bool nurse=user=="nurse";
                QString stack=nurse?"nurseStackView":"doctorStackView";
                js(workspace,stack+".push(patientsPage)");
                pause();
                auto *reg=js(workspace,stack+".currentItem").value<QObject*>();
                js(reg,"searchField.text='0000000000000101'");
                check(js(reg,"filteredPatients.length").toInt()==1 && js(reg,"filteredPatients[0].discharged").toBool(),"QML search and registry "+user);
                const QString uiPolicy="0000000000000110";
                if(nurse){
                    js(workspace,"registerPopup.openForm();regName.text='Мария';regSurname.text='Экранная';regPolicy.text='0000000000000110';regWeeks.text='37';registerSave.clicked()");
                    pause();
                    check(match(service->getPatients(),"policy",uiPolicy)["full_name"]=="Экранная Мария","QML registration submit");
                } else {
                    auto pid=match(service->getPatients(),"policy",uiPolicy)["id"].toInt();
                    QString prefix="transferPopup.openFor("+QString::number(pid)+",'Экранная Мария',false,";
                    if(user=="doctor"){
                        js(workspace,prefix+"true);transferSave.clicked()");
                        check(match(service->getPatients(),"policy",uiPolicy)["status"]=="В операционной","QML transfer commit");
                        js(reg,"searchField.text='0000000000000110'");
                        check(js(reg,"filteredPatients[0].status").toString()=="В операционной","same registry updated after transfer");
                        js(workspace,prefix+"false);deptCombo.currentIndex=transferPopup.departmentsData.findIndex(d=>d.kind==='postpartum');transferSave.clicked()");
                        check(js(reg,"filteredPatients[0].chamber").toString()=="301","QML department and registry refresh");
                    } else {
                        js(workspace,"dischargeDialog.patientId="+QString::number(pid)+";dischargeDay.text=Qt.formatDate(new Date(),'yyyy-MM-dd');dischargeRecommendations.text='Учебная запись';dischargeDialog.open();dischargeDialog.accept()");
                        pause();
                        check(match(service->getPatients(),"policy",uiPolicy)["discharged"].toBool(),"QML discharge commit");
                        js(workspace,"historyPopup.openFor("+QString::number(pid)+",'Экранная Мария')");
                        check(js(workspace,"historyPopup.events.length").toInt()==3,"QML discharge history");
                        js(workspace,"historyPopup.close()");
                    }
                }
                if(!nurse){
                    js(workspace,"statisticsPopup.showStats()");
                    check(js(workspace,"statisticsPopup.entries.length").toInt()==4,"QML statistics");
                    js(workspace,"statisticsPopup.close()");
                    js(workspace,"transferPopup.openFor(1,'Тест',true,true)");
                    check(js(workspace,"transferPopup.departmentsData.length").toInt()==1,"QML operating-room filter");
                    js(workspace,"transferPopup.close()");
                    js(workspace,"doctorStackView.push(mapPage,{deptId:"+QString::number(match(service->getDepartments(),"kind","postpartum")["id"].toInt())+",deptName:'Послеродовое отделение'})");
                    pause();
                    auto *map=js(workspace,"doctorStackView.currentItem").value<QObject*>();
                    check(js(map,"chambers.length").toInt()==2,"map room details");
                    if(user=="doctor"){
                        // A second employee moves a different patient while the map stays open.
                        QProcess other;
                        other.setProcessChannelMode(QProcess::ForwardedChannels);
                        other.start(QCoreApplication::applicationFilePath(),{"move-isolation"});
                        check(other.waitForFinished(15000) && other.exitCode()==0,"independent client committed");
                        for(int i=0;i<95 && !js(map,"chambers.some(c=>c.number===302 && c.free_places===0)").toBool();++i){
                            app.processEvents();QThread::msleep(100);
                        }
                        check(js(map,"chambers.some(c=>c.number===302 && c.free_places===0)").toBool(),"visible map refreshed by timer");
                    }

                }
            }
            js(workspace,"logoutButton.clicked()");
            pause();
        }
        check(service->loginUser(account("doctor"),secret).contains('|'),"map outage setup");
        js(window,"stackView.push('DoctorPage.qml')");
        pause();
        auto *lastPage=current();
        auto post=match(service->getDepartments(),"kind","postpartum")["id"].toInt();
        js(lastPage,"doctorStackView.push(mapPage,{deptId:"+QString::number(post)+"})");
        pause();
        auto *lastMap=js(lastPage,"doctorStackView.currentItem").value<QObject*>();
        int cached=js(lastMap,"chambers.length").toInt();
        QSqlDatabase::database("perinatal_connection").close();
        js(lastMap,"loadChambers()");
        check(cached==2 && js(lastMap,"chambers.length").toInt()==cached && !service->readError().isEmpty(),"map retains snapshot and marks connection loss");
        for (const QString &type:QStringList{"UserPage","DepartamentsView","ChambersView","StatisticsPopup"}) {
            QQmlComponent component(&engine); component.loadFromModule("PerinatalCenter",type);
            std::unique_ptr<QObject> object(component.create());
            check(object!=nullptr,"QML "+type);
        }
    } else if(mode=="offline"){
        check(!db.connectToDatabase("127.0.0.1",1,database,qEnvironmentVariable("PC_SQL_ROLE"),{}).isEmpty(),"unavailable server");
        check(!db.loginUser("testadmin",secret).contains('|'),"no offline login");
    } else return 1;
    return 0;
}
