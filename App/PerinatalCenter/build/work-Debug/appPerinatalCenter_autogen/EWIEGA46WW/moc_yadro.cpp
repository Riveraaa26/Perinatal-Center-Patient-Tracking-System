/****************************************************************************
** Meta object code from reading C++ file 'yadro.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.11.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../yadro.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'yadro.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 69
#error "This file was generated using the moc from 6.11.1. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN5YadroE_t {};
} // unnamed namespace

template <> constexpr inline auto Yadro::qt_create_metaobjectdata<qt_meta_tag_ZN5YadroE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "Yadro",
        "QML.Element",
        "auto",
        "QML.Singleton",
        "true",
        "connectToDatabase",
        "",
        "host",
        "port",
        "dbName",
        "user",
        "password",
        "loginUser",
        "login",
        "getEmployees",
        "QVariantList",
        "getRoles",
        "updateEmployee",
        "id",
        "name",
        "sourName",
        "roleId",
        "createEmployee",
        "deleteEmployee",
        "setEmployeeBlocked",
        "blocked",
        "getDepartments",
        "createDepartment",
        "capacity",
        "capacityDisease",
        "chambers",
        "updateDepartmentName",
        "deleteDepartment",
        "getChambersByDepartment",
        "departmentId",
        "chamberExists",
        "number",
        "addChamber",
        "isDisease",
        "deleteChamberByNumber",
        "getPatients",
        "getTransfers",
        "createPatient",
        "policy",
        "pregnancyPeriod",
        "getPatientsByChamber",
        "chamberNumber",
        "transferPatient",
        "patientId",
        "employeeId",
        "dischargePatient",
        "getTransferHistory"
    };

    QtMocHelpers::UintData qt_methods {
        // Method 'connectToDatabase'
        QtMocHelpers::MethodData<QString(const QString &, int, const QString &, const QString &, const QString &)>(5, 6, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::QString, 7 }, { QMetaType::Int, 8 }, { QMetaType::QString, 9 }, { QMetaType::QString, 10 },
            { QMetaType::QString, 11 },
        }}),
        // Method 'loginUser'
        QtMocHelpers::MethodData<QString(const QString &, const QString &)>(12, 6, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::QString, 13 }, { QMetaType::QString, 11 },
        }}),
        // Method 'getEmployees'
        QtMocHelpers::MethodData<QVariantList()>(14, 6, QMC::AccessPublic, 0x80000000 | 15),
        // Method 'getRoles'
        QtMocHelpers::MethodData<QVariantList()>(16, 6, QMC::AccessPublic, 0x80000000 | 15),
        // Method 'updateEmployee'
        QtMocHelpers::MethodData<QString(int, const QString &, const QString &, const QString &, const QString &, int)>(17, 6, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::Int, 18 }, { QMetaType::QString, 19 }, { QMetaType::QString, 20 }, { QMetaType::QString, 13 },
            { QMetaType::QString, 11 }, { QMetaType::Int, 21 },
        }}),
        // Method 'createEmployee'
        QtMocHelpers::MethodData<QString(const QString &, const QString &, const QString &, const QString &, int)>(22, 6, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::QString, 19 }, { QMetaType::QString, 20 }, { QMetaType::QString, 13 }, { QMetaType::QString, 11 },
            { QMetaType::Int, 21 },
        }}),
        // Method 'deleteEmployee'
        QtMocHelpers::MethodData<QString(int)>(23, 6, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::Int, 18 },
        }}),
        // Method 'setEmployeeBlocked'
        QtMocHelpers::MethodData<QString(int, bool)>(24, 6, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::Int, 18 }, { QMetaType::Bool, 25 },
        }}),
        // Method 'getDepartments'
        QtMocHelpers::MethodData<QVariantList()>(26, 6, QMC::AccessPublic, 0x80000000 | 15),
        // Method 'createDepartment'
        QtMocHelpers::MethodData<QString(const QString &, int, int, const QVariantList &)>(27, 6, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::QString, 19 }, { QMetaType::Int, 28 }, { QMetaType::Int, 29 }, { 0x80000000 | 15, 30 },
        }}),
        // Method 'updateDepartmentName'
        QtMocHelpers::MethodData<QString(int, const QString &)>(31, 6, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::Int, 18 }, { QMetaType::QString, 19 },
        }}),
        // Method 'deleteDepartment'
        QtMocHelpers::MethodData<QString(int)>(32, 6, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::Int, 18 },
        }}),
        // Method 'getChambersByDepartment'
        QtMocHelpers::MethodData<QVariantList(int)>(33, 6, QMC::AccessPublic, 0x80000000 | 15, {{
            { QMetaType::Int, 34 },
        }}),
        // Method 'chamberExists'
        QtMocHelpers::MethodData<bool(int, int)>(35, 6, QMC::AccessPublic, QMetaType::Bool, {{
            { QMetaType::Int, 34 }, { QMetaType::Int, 36 },
        }}),
        // Method 'addChamber'
        QtMocHelpers::MethodData<QString(int, int, int, bool)>(37, 6, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::Int, 34 }, { QMetaType::Int, 36 }, { QMetaType::Int, 28 }, { QMetaType::Bool, 38 },
        }}),
        // Method 'deleteChamberByNumber'
        QtMocHelpers::MethodData<QString(int, int)>(39, 6, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::Int, 34 }, { QMetaType::Int, 36 },
        }}),
        // Method 'getPatients'
        QtMocHelpers::MethodData<QVariantList()>(40, 6, QMC::AccessPublic, 0x80000000 | 15),
        // Method 'getTransfers'
        QtMocHelpers::MethodData<QVariantList()>(41, 6, QMC::AccessPublic, 0x80000000 | 15),
        // Method 'createPatient'
        QtMocHelpers::MethodData<QString(const QString &, const QString &, const QString &, const QString &, bool)>(42, 6, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::QString, 19 }, { QMetaType::QString, 20 }, { QMetaType::QString, 43 }, { QMetaType::QString, 44 },
            { QMetaType::Bool, 38 },
        }}),
        // Method 'getPatientsByChamber'
        QtMocHelpers::MethodData<QVariantList(int, int)>(45, 6, QMC::AccessPublic, 0x80000000 | 15, {{
            { QMetaType::Int, 34 }, { QMetaType::Int, 46 },
        }}),
        // Method 'transferPatient'
        QtMocHelpers::MethodData<QString(int, int, int, int)>(47, 6, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::Int, 48 }, { QMetaType::Int, 34 }, { QMetaType::Int, 46 }, { QMetaType::Int, 49 },
        }}),
        // Method 'dischargePatient'
        QtMocHelpers::MethodData<QString(int, int)>(50, 6, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::Int, 48 }, { QMetaType::Int, 49 },
        }}),
        // Method 'getTransferHistory'
        QtMocHelpers::MethodData<QVariantList()>(51, 6, QMC::AccessPublic, 0x80000000 | 15),
    };
    QtMocHelpers::UintData qt_properties {
    };
    QtMocHelpers::UintData qt_enums {
    };
    QtMocHelpers::UintData qt_constructors {};
    QtMocHelpers::ClassInfos qt_classinfo({
            {    1,    2 },
            {    3,    4 },
    });
    return QtMocHelpers::metaObjectData<Yadro, void>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums, qt_constructors, qt_classinfo);
}
Q_CONSTINIT const QMetaObject Yadro::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN5YadroE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN5YadroE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN5YadroE_t>.metaTypes,
    nullptr
} };

void Yadro::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<Yadro *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: { QString _r = _t->connectToDatabase((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[4])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[5])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 1: { QString _r = _t->loginUser((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 2: { QVariantList _r = _t->getEmployees();
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 3: { QVariantList _r = _t->getRoles();
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 4: { QString _r = _t->updateEmployee((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[4])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[5])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[6])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 5: { QString _r = _t->createEmployee((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[4])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[5])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 6: { QString _r = _t->deleteEmployee((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 7: { QString _r = _t->setEmployeeBlocked((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<bool>>(_a[2])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 8: { QVariantList _r = _t->getDepartments();
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 9: { QString _r = _t->createDepartment((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[3])),(*reinterpret_cast<std::add_pointer_t<QVariantList>>(_a[4])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 10: { QString _r = _t->updateDepartmentName((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 11: { QString _r = _t->deleteDepartment((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 12: { QVariantList _r = _t->getChambersByDepartment((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 13: { bool _r = _t->chamberExists((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[2])));
            if (_a[0]) *reinterpret_cast<bool*>(_a[0]) = std::move(_r); }  break;
        case 14: { QString _r = _t->addChamber((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[3])),(*reinterpret_cast<std::add_pointer_t<bool>>(_a[4])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 15: { QString _r = _t->deleteChamberByNumber((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[2])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 16: { QVariantList _r = _t->getPatients();
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 17: { QVariantList _r = _t->getTransfers();
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 18: { QString _r = _t->createPatient((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[4])),(*reinterpret_cast<std::add_pointer_t<bool>>(_a[5])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 19: { QVariantList _r = _t->getPatientsByChamber((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[2])));
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 20: { QString _r = _t->transferPatient((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[3])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[4])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 21: { QString _r = _t->dischargePatient((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[2])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 22: { QVariantList _r = _t->getTransferHistory();
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        default: ;
        }
    }
}

const QMetaObject *Yadro::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *Yadro::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN5YadroE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int Yadro::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 23)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 23;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 23)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 23;
    }
    return _id;
}
QT_WARNING_POP
