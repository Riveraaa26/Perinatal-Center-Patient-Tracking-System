cmake_minimum_required(VERSION 3.16)
project(PerinatalCenter VERSION 1.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick QuickControls2 Sql)
qt_standard_project_setup(REQUIRES 6.5)

option(PERINATAL_TEST_DRIVER "Build the isolated integration test driver" OFF)
if(PERINATAL_TEST_DRIVER)
    qt_add_executable(appPerinatalCenter tests/driver.cpp)
    target_include_directories(appPerinatalCenter PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
else()
    qt_add_executable(appPerinatalCenter main.cpp)
endif()

qt_add_qml_module(appPerinatalCenter
    URI PerinatalCenter
    VERSION 1.0
    QML_FILES
        UserPage.qml
        Main.qml
        LoginPage.qml
        AdminPage.qml
        NursePage.qml
        DoctorPage.qml
        DepartamentsView.qml
        ChambersView.qml
        StatisticsPopup.qml
    SOURCES
        yadro.h
        yadro.cpp
)

set_target_properties(appPerinatalCenter PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

target_link_libraries(appPerinatalCenter PRIVATE Qt6::Quick Qt6::QuickControls2 Qt6::Sql)
