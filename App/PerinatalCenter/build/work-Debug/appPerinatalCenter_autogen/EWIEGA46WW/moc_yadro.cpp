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
        "getChambersByDepartment",
        "QVariantList",
        "departmentId",
        "getEmployees",
        "getRoles",
        "updateEmployee",
        "id",
        "name",
        "sourName",
        "roleId",
        "createEmployee",
        "deleteEmployee",
        "getDepartments",
        "createDepartment",
        "capacity",
        "capacityDisease",
        "chambers",
        "updateDepartmentName",
        "deleteDepartment",
        "getNextChamberNumber",
        "addChamber",
        "number",
        "isDisease",
        "getLastChamber",
        "QVariantMap",
        "getLastChamberByType",
        "deleteChamber",
        "chamberId",
        "getPatients",
        "getTransfers"
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
        // Method 'getChambersByDepartment'
        QtMocHelpers::MethodData<QVariantList(int)>(14, 6, QMC::AccessPublic, 0x80000000 | 15, {{
            { QMetaType::Int, 16 },
        }}),
        // Method 'getEmployees'
        QtMocHelpers::MethodData<QVariantList()>(17, 6, QMC::AccessPublic, 0x80000000 | 15),
        // Method 'getRoles'
        QtMocHelpers::MethodData<QVariantList()>(18, 6, QMC::AccessPublic, 0x80000000 | 15),
        // Method 'updateEmployee'
        QtMocHelpers::MethodData<QString(int, const QString &, const QString &, const QString &, const QString &, int)>(19, 6, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::Int, 20 }, { QMetaType::QString, 21 }, { QMetaType::QString, 22 }, { QMetaType::QString, 13 },
            { QMetaType::QString, 11 }, { QMetaType::Int, 23 },
        }}),
        // Method 'createEmployee'
        QtMocHelpers::MethodData<QString(const QString &, const QString &, const QString &, const QString &, int)>(24, 6, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::QString, 21 }, { QMetaType::QString, 22 }, { QMetaType::QString, 13 }, { QMetaType::QString, 11 },
            { QMetaType::Int, 23 },
        }}),
        // Method 'deleteEmployee'
        QtMocHelpers::MethodData<QString(int)>(25, 6, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::Int, 20 },
        }}),
        // Method 'getDepartments'
        QtMocHelpers::MethodData<QVariantList()>(26, 6, QMC::AccessPublic, 0x80000000 | 15),
        // Method 'createDepartment'
        QtMocHelpers::MethodData<QString(const QString &, int, int, const QVariantList &)>(27, 6, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::QString, 21 }, { QMetaType::Int, 28 }, { QMetaType::Int, 29 }, { 0x80000000 | 15, 30 },
        }}),
        // Method 'updateDepartmentName'
        QtMocHelpers::MethodData<QString(int, const QString &)>(31, 6, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::Int, 20 }, { QMetaType::QString, 21 },
        }}),
        // Method 'deleteDepartment'
        QtMocHelpers::MethodData<QString(int)>(32, 6, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::Int, 20 },
        }}),
        // Method 'getNextChamberNumber'
        QtMocHelpers::MethodData<int(int)>(33, 6, QMC::AccessPublic, QMetaType::Int, {{
            { QMetaType::Int, 16 },
        }}),
        // Method 'addChamber'
        QtMocHelpers::MethodData<QString(int, int, int, bool)>(34, 6, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::Int, 16 }, { QMetaType::Int, 35 }, { QMetaType::Int, 28 }, { QMetaType::Bool, 36 },
        }}),
        // Method 'getLastChamber'
        QtMocHelpers::MethodData<QVariantMap(int)>(37, 6, QMC::AccessPublic, 0x80000000 | 38, {{
            { QMetaType::Int, 16 },
        }}),
        // Method 'getLastChamberByType'
        QtMocHelpers::MethodData<QVariantMap(int, bool)>(39, 6, QMC::AccessPublic, 0x80000000 | 38, {{
            { QMetaType::Int, 16 }, { QMetaType::Bool, 36 },
        }}),
        // Method 'deleteChamber'
        QtMocHelpers::MethodData<QString(int)>(40, 6, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::Int, 41 },
        }}),
        // Method 'getPatients'
        QtMocHelpers::MethodData<QVariantList()>(42, 6, QMC::AccessPublic, 0x80000000 | 15),
        // Method 'getTransfers'
        QtMocHelpers::MethodData<QVariantList()>(43, 6, QMC::AccessPublic, 0x80000000 | 15),
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
        case 2: { QVariantList _r = _t->getChambersByDepartment((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 3: { QVariantList _r = _t->getEmployees();
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 4: { QVariantList _r = _t->getRoles();
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 5: { QString _r = _t->updateEmployee((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[4])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[5])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[6])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 6: { QString _r = _t->createEmployee((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[4])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[5])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 7: { QString _r = _t->deleteEmployee((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 8: { QVariantList _r = _t->getDepartments();
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 9: { QString _r = _t->createDepartment((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[3])),(*reinterpret_cast<std::add_pointer_t<QVariantList>>(_a[4])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 10: { QString _r = _t->updateDepartmentName((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 11: { QString _r = _t->deleteDepartment((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 12: { int _r = _t->getNextChamberNumber((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast<int*>(_a[0]) = std::move(_r); }  break;
        case 13: { QString _r = _t->addChamber((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[3])),(*reinterpret_cast<std::add_pointer_t<bool>>(_a[4])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 14: { QVariantMap _r = _t->getLastChamber((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast<QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 15: { QVariantMap _r = _t->getLastChamberByType((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<bool>>(_a[2])));
            if (_a[0]) *reinterpret_cast<QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 16: { QString _r = _t->deleteChamber((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 17: { QVariantList _r = _t->getPatients();
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 18: { QVariantList _r = _t->getTransfers();
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
        if (_id < 19)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 19;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 19)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 19;
    }
    return _id;
}
QT_WARNING_POP
