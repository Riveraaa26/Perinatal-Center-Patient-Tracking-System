cmake_minimum_required(VERSION 3.16)

project(PerinatalCenter VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Sql)

qt_standard_project_setup(REQUIRES 6.5)

set(QML_IMPORT_PATH "${CMAKE_BINARY_DIR}/qml" CACHE STRING "QML import path" FORCE)

qt_add_executable(appPerinatalCenter
    main.cpp
    yadro.cpp
    yadro.h
)

qt_add_qml_module(appPerinatalCenter
    URI PerinatalCenter
    VERSION 1.0
    QML_FILES
        Main.qml
        LoginPage.qml
        AdminPage.qml
        UserPage.qml
        DepartamentsView.qml
        ChambersView.qml
    SOURCES
        yadro.cpp
        yadro.h
        UserPage.qml
)

set_target_properties(appPerinatalCenter PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appPerinatalCenter
    PRIVATE Qt6::Quick Qt6::QuickControls2 Qt6::Sql
)

install(TARGETS appPerinatalCenter
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)