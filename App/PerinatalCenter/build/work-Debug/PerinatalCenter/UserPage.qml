import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PerinatalCenter 1.0

Item {
    id: userPage

    property string currentUserLogin: ""
    property string currentUserFullName: ""

    property string currentTab: "departments"

    // ==========================================
    // 1. ШАПКА
    // ==========================================
    Text {
        id: roleText
        text: "Медсестра"
        font.pixelSize: 20
        font.bold: true
        color: "#333333"
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 40
    }

    Text {
        id: centerText
        text: userPage.currentUserFullName
        font.pixelSize: 24
        font.bold: true
        color: "#333333"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: roleText.verticalCenter
    }

    Button {
        id: logoutButton
        text: "Выйти"
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: roleText.verticalCenter
        implicitWidth: 100
        implicitHeight: 35
        font.pixelSize: 14
        onClicked: {
            stackView.pop()
        }
    }

    Rectangle {
        id: headerLine
        width: parent.width
        height: 2
        color: "#d3d3d3"
        anchors.top: roleText.bottom
        anchors.topMargin: 30
    }

    // ==========================================
    // 2. САЙДБАР
    // ==========================================
    Rectangle {
        id: sidebar
        width: 200
        anchors.top: headerLine.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        color: "#f4f7f6"
        border.color: "#e0e0e0"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10

            Button {
                text: "Отделения"
                Layout.fillWidth: true
                implicitHeight: 40
                font.pixelSize: 15
                background: Rectangle {
                    color: parent.down ? "#e0e0e0" : (parent.hovered ? "#eeeeee" : "#ffffff")
                    border.color: "#cccccc"
                    radius: 4
                }
                onClicked: {
                    userPage.currentTab = "departments"
                    userStackView.pop(null)
                }
            }

            Button {
                text: "Пациенты"
                Layout.fillWidth: true
                implicitHeight: 40
                font.pixelSize: 15
                background: Rectangle {
                    color: parent.down ? "#e0e0e0" : (parent.hovered ? "#eeeeee" : "#ffffff")
                    border.color: "#cccccc"
                    radius: 4
                }
                onClicked: {
                    userPage.currentTab = "patients"
                    userStackView.pop(null)
                    userStackView.push(patientsPage)
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    // ==========================================
    // 3. РАБОЧАЯ ЗОНА
    // ==========================================
    Item {
        id: contentArea
        anchors.top: headerLine.bottom
        anchors.bottom: parent.bottom
        anchors.left: sidebar.right
        anchors.right: parent.right
        clip: true

        StackView {
            id: userStackView
            anchors.fill: parent

            // СТРАНИЦА 1: ОТДЕЛЕНИЯ
            initialItem: Item {
                Component.onCompleted: {
                    deptModel.model = Yadro.getDepartments()
                }

                Text {
                    id: pageTitle
                    text: "Отделения"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333333"
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                }

                Rectangle {
                    anchors.top: pageTitle.bottom
                    anchors.topMargin: 15
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 20

                    color: "#ffffff"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 8

                    ListView {
                        id: deptModel
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        highlightFollowsCurrentItem: false
                        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded; width: 10 }

                        header: Rectangle {
                            width: deptModel.width - 10
                            height: 35
                            color: "#f0f0f0"
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 10
                                Text { text: "Название отделения"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14 }
                                Text { text: "Всего палат"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14 }
                                Text { text: "Инкубаторов"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14 }
                            }
                        }

                        delegate: Rectangle {
                            width: deptModel.width - 10
                            height: 40
                            color: deptModel.currentIndex === index ? "#cce5ff" : (index % 2 === 0 ? "#ffffff" : "#f9f9f9")
                            border.color: "#eeeeee"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 10
                                Text { text: modelData.name; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                                Text { text: modelData.capacity; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14 }
                                Text { text: modelData.capacity_disease; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14 }
                            }

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton
                                onClicked: {
                                    deptModel.currentIndex = index
                                }
                                onDoubleClicked: {
                                    userStackView.push(chambersPage, {
                                        "deptId": parseInt(modelData.id),
                                        "deptName": modelData.name
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // 4. СТРАНИЦА ПАЛАТ
    // ==========================================
    Component {
        id: chambersPage

        Item {
            id: chambersItem
            property int deptId: -1
            property string deptName: ""

            Component.onCompleted: {
                chamberModel.model = Yadro.getChambersByDepartment(chambersItem.deptId)
            }

            Text {
                id: chamberTitle
                text: chambersItem.deptName
                font.pixelSize: 22
                font.bold: true
                color: "#333333"
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.leftMargin: 20
            }

            RowLayout {
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.top: parent.top
                anchors.topMargin: 15
                spacing: 10

                Button {
                    text: "Обновить"
                    implicitWidth: 100
                    implicitHeight: 35
                    font.pixelSize: 14
                    onClicked: {
                        chamberModel.model = Yadro.getChambersByDepartment(chambersItem.deptId)
                    }
                }

                Button {
                    text: "Назад"
                    implicitWidth: 100
                    implicitHeight: 35
                    font.pixelSize: 14
                    onClicked: {
                        userStackView.pop()
                    }
                }
            }

            Rectangle {
                anchors.top: chamberTitle.bottom
                anchors.topMargin: 15
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20

                color: "#ffffff"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 8

                ListView {
                    id: chamberModel
                    anchors.fill: parent
                    anchors.margins: 10
                    clip: true
                    highlightFollowsCurrentItem: false
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded; width: 10 }

                    header: Rectangle {
                        width: chamberModel.width - 10
                        height: 35
                        color: "#f0f0f0"
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10
                            Text { text: "Номер"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14 }
                            Text { text: "Тип"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14 }
                            Text { text: "Всего мест"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14 }
                            Text { text: "Свободно"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14 }
                        }
                    }

                    delegate: Rectangle {
                        width: chamberModel.width - 10
                        height: 40
                        color: index % 2 === 0 ? "#ffffff" : "#f9f9f9"
                        border.color: "#eeeeee"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10
                            Text { text: modelData.number; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text {
                                text: modelData.disease ? "Инкубатор" : "Обычная"
                                Layout.fillWidth: true; Layout.preferredWidth: 1
                                elide: Text.ElideRight
                                font.pixelSize: 14
                                color: modelData.disease ? "#d9534f" : "#333333"
                            }
                            Text { text: modelData.capacity; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text {
                                text: modelData.free_places
                                Layout.fillWidth: true; Layout.preferredWidth: 1
                                elide: Text.ElideRight
                                font.pixelSize: 14
                                font.bold: true
                                color: modelData.free_places > 0 ? "#16a34a" : "#d9534f"
                            }
                        }
                    }
                }

                Text {
                    text: "В этом отделении пока нет палат"
                    anchors.centerIn: parent
                    color: "#999999"
                    visible: chamberModel.count === 0
                }
            }
        }
    }

    // ==========================================
    // 5. СТРАНИЦА ПАЦИЕНТОВ
    // ==========================================
    Component {
        id: patientsPage

        Item {
            id: patientsItem

            Component.onCompleted: {
                patientModel.model = Yadro.getPatients()
            }

            Text {
                id: pageTitle
                text: "Пациенты"
                font.pixelSize: 22
                font.bold: true
                color: "#333333"
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.leftMargin: 20
            }

            // ✅ БЛОК КНОПОК СПРАВА (Обновить + Назад)
            RowLayout {
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.top: parent.top
                anchors.topMargin: 15
                spacing: 10

                Button {
                    text: "Обновить"
                    implicitWidth: 100
                    implicitHeight: 35
                    font.pixelSize: 14
                    onClicked: {
                        patientModel.model = Yadro.getPatients()
                    }
                }

                Button {
                    text: "Назад"
                    implicitWidth: 100
                    implicitHeight: 35
                    font.pixelSize: 14
                    onClicked: {
                        userPage.currentTab = "departments"
                        userStackView.pop(null)
                    }
                }
            }

            Rectangle {
                anchors.top: pageTitle.bottom
                anchors.topMargin: 15
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20

                color: "#ffffff"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 8

                ListView {
                    id: patientModel
                    anchors.fill: parent
                    anchors.margins: 10
                    clip: true
                    highlightFollowsCurrentItem: false
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded; width: 10 }

                    header: Rectangle {
                        width: patientModel.width - 10
                        height: 35
                        color: "#f0f0f0"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Text { text: "ФИО"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14 }
                            Text { text: "Полис"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14 }
                            Text { text: "Срок"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14 }
                            Text { text: "Болезнь"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14 }
                            Text { text: "Отделение"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14 }
                            Text { text: "Палата"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14 }
                        }
                    }

                    delegate: Rectangle {
                        width: patientModel.width - 10
                        height: 40
                        color: index % 2 === 0 ? "#ffffff" : "#f9f9f9"
                        border.color: "#eeeeee"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Text { text: modelData.full_name !== "" ? modelData.full_name : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text { text: modelData.policy !== "" ? modelData.policy : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text { text: modelData.pregnancy_period !== "" ? modelData.pregnancy_period : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text { text: modelData.disease !== "" ? modelData.disease : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text { text: modelData.department !== "" ? modelData.department : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text { text: modelData.chamber !== "" ? modelData.chamber : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                        }
                    }
                }

                Text {
                    text: "В базе пока нет пациентов"
                    anchors.centerIn: parent
                    color: "#999999"
                    visible: patientModel.count === 0
                }
            }
        }
    }
}