import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PerinatalCenter 1.0

Item {
    id: nursePage

    property string currentUserLogin: ""
    property string currentUserFullName: ""
    property int currentEmployeeId: -1

    // Цветовая палитра
    property color accentColor: "#ffb3c6"
    property color accentHover: "#ff8fab"

    // ==========================================
    // 1. ШАПКА
    // ==========================================
    Row {
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 30
        spacing: 10

        Text {
            text: "💉"
            font.pixelSize: 32
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                id: roleText
                text: "Медицинская сестра"
                font.pixelSize: 20
                font.bold: true
                color: "#333333"
            }
            Text {
                text: "Перинатальный центр"
                font.pixelSize: 13
                font.italic: true
                color: "#888888"
            }
        }
    }

    Text {
        id: centerText
        text: nursePage.currentUserFullName
        font.pixelSize: 24
        font.bold: true
        color: accentHover
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.top
        anchors.verticalCenterOffset: 50
    }

    Button {
        id: logoutButton
        text: "Выйти"
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.top
        anchors.verticalCenterOffset: 50
        implicitWidth: 100
        implicitHeight: 35
        font.pixelSize: 14
        background: Rectangle {
            color: parent.down ? "#e0e0e0" : (parent.hovered ? "#f5f5f5" : "#ffffff")
            border.color: "#cccccc"
            radius: 8
        }
        onClicked: stackView.pop()
    }

    Rectangle {
        id: headerLine
        width: parent.width
        height: 2
        color: "#d3d3d3"
        anchors.top: parent.top
        anchors.topMargin: 90
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
                text: "📖 Журнал переводов"
                Layout.fillWidth: true
                implicitHeight: 40
                font.pixelSize: 15
                background: Rectangle {
                    color: parent.down ? accentColor : (parent.hovered ? "#fff0f5" : "#ffffff")
                    border.color: parent.hovered ? accentColor : "#cccccc"
                    radius: 8
                }
                onClicked: {
                    nurseStackView.pop(null)
                    nurseStackView.push(historyPage)
                }
            }

            Button {
                text: "🏥 Отделения"
                Layout.fillWidth: true
                implicitHeight: 40
                font.pixelSize: 15
                background: Rectangle {
                    color: parent.down ? accentColor : (parent.hovered ? "#fff0f5" : "#ffffff")
                    border.color: parent.hovered ? accentColor : "#cccccc"
                    radius: 8
                }
                onClicked: {
                    nurseStackView.pop(null)
                    nurseStackView.push(departmentsPage)
                }
            }

            Button {
                text: "🧕 Пациенты"
                Layout.fillWidth: true
                implicitHeight: 40
                font.pixelSize: 15
                background: Rectangle {
                    color: parent.down ? accentColor : (parent.hovered ? "#fff0f5" : "#ffffff")
                    border.color: parent.hovered ? accentColor : "#cccccc"
                    radius: 8
                }
                onClicked: {
                    nurseStackView.pop(null)
                    nurseStackView.push(patientsPage)
                }
            }

            Item { Layout.fillHeight: true }

            // Красивая плашка "Берегите себя"
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                Layout.bottomMargin: 10
                color: "#fff0f5"
                border.color: "#ffb3c6"
                border.width: 1
                radius: 12

                Text {
                    text: "Берегите себя! 🎀"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#ff8fab"
                    anchors.centerIn: parent
                }
            }
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
            id: nurseStackView
            anchors.fill: parent
            initialItem: historyPage
        }
    }

    // ==========================================
    // 4. ЖУРНАЛ ПЕРЕВОДОВ
    // ==========================================
    Component {
        id: historyPage

        Item {
            id: historyItem
            property var historyList: []

            Component.onCompleted: loadHistory()

            function loadHistory() {
                historyItem.historyList = Yadro.getTransfers()
            }

            Text {
                id: pageTitle
                text: "📖 Журнал переводов"
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
                    background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 8 }
                    onClicked: historyItem.loadHistory()
                }

                Button {
                    text: "Назад"
                    implicitWidth: 100
                    implicitHeight: 35
                    font.pixelSize: 14
                    background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 8 }
                    onClicked: {
                        nurseStackView.pop(null)
                        nurseStackView.push(departmentsPage)
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
                radius: 12

                ListView {
                    id: historyListView
                    anchors.fill: parent
                    anchors.margins: 10
                    clip: true
                    model: historyItem.historyList
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded; width: 10 }

                    header: Rectangle {
                        width: historyListView.width - 10
                        height: 35
                        color: "#fff0f5"
                        radius: 8
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10
                            Text { text: "Дата"; font.bold: true; Layout.preferredWidth: 120; font.pixelSize: 14; color: "#4a4a4a" }
                            Text { text: "Пациентка"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 2; font.pixelSize: 14; color: "#4a4a4a" }
                            Text { text: "Сотрудник (кто перевел)"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 2; font.pixelSize: 14; color: "#4a4a4a" }
                            Text { text: "Отделение"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14; color: "#4a4a4a" }
                            Text { text: "Палата"; font.bold: true; Layout.preferredWidth: 80; font.pixelSize: 14; color: "#4a4a4a" }
                        }
                    }

                    delegate: Rectangle {
                        width: historyListView.width - 10
                        height: 40
                        color: index % 2 === 0 ? "#ffffff" : "#fcfcfc"
                        border.color: "#eeeeee"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Text { text: modelData.date; Layout.preferredWidth: 120; font.pixelSize: 14; color: "#666" }
                            Text { text: modelData.patient; Layout.fillWidth: true; Layout.preferredWidth: 2; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text { text: modelData.employee; Layout.fillWidth: true; Layout.preferredWidth: 2; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text { text: modelData.department; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text { text: modelData.chamber; Layout.preferredWidth: 80; elide: Text.ElideRight; font.pixelSize: 14 }
                        }
                    }
                }

                Text {
                    text: "История переводов пуста 💉"
                    anchors.centerIn: parent
                    color: "#999999"
                    visible: historyListView.count === 0
                    font.pixelSize: 16
                }
            }
        }
    }

    // ==========================================
    // 5. ОТДЕЛЕНИЯ
    // ==========================================
    Component {
        id: departmentsPage

        Item {
            id: deptItem
            property var departments: []

            Component.onCompleted: loadDepartments()

            function loadDepartments() {
                departments = Yadro.getDepartments()
            }

            Text {
                id: pageTitle
                text: "🏥 Отделения"
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
                radius: 12

                ListView {
                    id: deptModel
                    anchors.fill: parent
                    anchors.margins: 10
                    clip: true
                    model: deptItem.departments
                    highlightFollowsCurrentItem: false
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded; width: 10 }

                    header: Rectangle {
                        width: deptModel.width - 10
                        height: 35
                        color: "#fff0f5"
                        radius: 8
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10
                            Text { text: "Название отделения"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14; color: "#4a4a4a" }
                            Text { text: "Всего палат"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14; color: "#4a4a4a" }
                            Text { text: "Изоляторов"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14; color: "#4a4a4a" }
                        }
                    }

                    delegate: Rectangle {
                        width: deptModel.width - 10
                        height: 40
                        color: deptModel.currentIndex === index ? "#e3f2fd" : (index % 2 === 0 ? "#ffffff" : "#fcfcfc")
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
                            onClicked: deptModel.currentIndex = index
                            onDoubleClicked: {
                                nurseStackView.push(mapPage, {
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

    // ==========================================
    // 6. КАРТА ПАЛАТ
    // ==========================================
    Component {
        id: mapPage

        Item {
            id: mapItem
            property int deptId: -1
            property string deptName: ""
            property var chambers: []

            Component.onCompleted: loadChambers()
            function loadChambers() { chambers = Yadro.getChambersByDepartment(mapItem.deptId) }

            Text {
                id: mapTitle
                text: "🎀 " + mapItem.deptName
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
                    background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 8 }
                    onClicked: mapItem.loadChambers()
                }

                Button {
                    text: "Назад"
                    implicitWidth: 100
                    implicitHeight: 35
                    font.pixelSize: 14
                    background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 8 }
                    onClicked: nurseStackView.pop()
                }
            }

            Rectangle {
                anchors.top: mapTitle.bottom
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
                radius: 12

                GridView {
                    id: chambersGrid
                    anchors.fill: parent
                    anchors.margins: 15
                    clip: true
                    cellWidth: 220
                    cellHeight: 140
                    model: mapItem.chambers

                    delegate: Item {
                        width: chambersGrid.cellWidth
                        height: chambersGrid.cellHeight

                        Rectangle {
                            width: parent.width - 20
                            height: parent.height - 20
                            anchors.centerIn: parent
                            radius: 12
                            color: modelData.free_places > 0 ? "#e8f5e9" : "#ffebee"
                            border.color: modelData.free_places > 0 ? "#a5d6a7" : "#ffcdd2"
                            border.width: 2

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 10
                                Text { text: "Палата " + modelData.number; font.pixelSize: 18; font.bold: true; color: "#333333"; Layout.fillWidth: true }
                                Text { text: "Тип: " + (modelData.disease ? "Изолятор" : "Обычная"); font.pixelSize: 14; color: "#555555"; Layout.fillWidth: true }
                                Text {
                                    text: "Свободно: " + modelData.free_places + " / " + modelData.capacity
                                    font.pixelSize: 14; font.bold: true
                                    color: modelData.free_places > 0 ? "#2e7d32" : "#c62828"
                                    Layout.fillWidth: true
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: nurseStackView.push(chamberPatientsPage, {
                                    "deptId": mapItem.deptId,
                                    "chamberNumber": parseInt(modelData.number),
                                    "chamberName": "Палата " + modelData.number
                                })
                            }
                        }
                    }
                }

                Text {
                    text: "В этом отделении пока нет палат 🧸"
                    anchors.centerIn: parent
                    color: "#999999"
                    visible: mapItem.chambers.length === 0
                    font.pixelSize: 16
                }
            }
        }
    }

    // ==========================================
    // 7. ПАЦИЕНТЫ ПАЛАТЫ
    // ==========================================
    Component {
        id: chamberPatientsPage

        Item {
            id: chamberPatItem
            property int deptId: -1
            property int chamberNumber: -1
            property string chamberName: ""
            property var patientsList: []

            Component.onCompleted: loadPatients()
            function loadPatients() {
                patientsList = Yadro.getPatientsByChamber(chamberPatItem.deptId, chamberPatItem.chamberNumber)
            }

            Text {
                id: pageTitle
                text: "🧕 " + chamberPatItem.chamberName
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
                    background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 8 }
                    onClicked: chamberPatItem.loadPatients()
                }

                Button {
                    text: "Назад"
                    implicitWidth: 100
                    implicitHeight: 35
                    font.pixelSize: 14
                    background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 8 }
                    onClicked: nurseStackView.pop()
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
                radius: 12

                ListView {
                    id: patientListModel
                    anchors.fill: parent
                    anchors.margins: 10
                    clip: true
                    highlightFollowsCurrentItem: false
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded; width: 10 }
                    model: chamberPatItem.patientsList

                    header: Rectangle {
                        width: patientListModel.width - 10
                        height: 35
                        color: "#fff0f5"
                        radius: 8

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10
                            Text { text: "ФИО"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 2; font.pixelSize: 14; color: "#4a4a4a" }
                            Text { text: "Полис"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14; color: "#4a4a4a" }
                            Text { text: "Срок"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14; color: "#4a4a4a" }
                            Text { text: "Болезнь"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14; color: "#4a4a4a" }
                        }
                    }

                    delegate: Rectangle {
                        width: patientListModel.width - 10
                        height: 40
                        color: patientListModel.currentIndex === index ? "#e3f2fd" : (index % 2 === 0 ? "#ffffff" : "#fcfcfc")
                        border.color: "#eeeeee"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Text { text: modelData.full_name !== "" ? modelData.full_name : "—"; Layout.fillWidth: true; Layout.preferredWidth: 2; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text { text: modelData.policy !== "" ? modelData.policy : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text { text: modelData.pregnancy_period !== "" ? modelData.pregnancy_period : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text {
                                text: modelData.disease ? "Да" : "Нет"
                                Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14
                            }
                        }
                    }
                }

                Text {
                    text: "В этой палате пока нет пациентов 🎀"
                    anchors.centerIn: parent
                    color: "#999999"
                    visible: patientListModel.count === 0
                    font.pixelSize: 16
                }
            }
        }
    }

    // ==========================================
    // 8. ВСЕ ПАЦИЕНТЫ
    // ==========================================
    Component {
        id: patientsPage

        Item {
            id: patientsItem

            property var allPatients: []
            property var filteredPatients: []

            Component.onCompleted: loadPatients()

            function loadPatients() {
                allPatients = Yadro.getPatients()
                patientsItem.filteredPatients = allPatients
                searchField.text = ""
            }

            function filterPatients() {
                let query = searchField.text.trim().toLowerCase()
                if (query === "") {
                    patientsItem.filteredPatients = patientsItem.allPatients
                    return
                }
                let result = []
                for (let i = 0; i < patientsItem.allPatients.length; i++) {
                    let pat = patientsItem.allPatients[i]
                    if (pat.full_name && pat.full_name.toLowerCase().includes(query))
                        result.push(pat)
                }
                patientsItem.filteredPatients = result
            }

            Text {
                id: pageTitle
                text: "🧕 Все пациенты"
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

                Rectangle {
                    width: 250
                    height: 35
                    color: "#ffffff"
                    border.color: "#cccccc"
                    radius: 8

                    TextField {
                        id: searchField
                        anchors.fill: parent
                        placeholderText: "Поиск по ФИО..."
                        font.pixelSize: 14
                        leftPadding: 15
                        rightPadding: 30
                        background: null
                        onTextChanged: patientsItem.filterPatients()
                    }

                    Button {
                        width: 24
                        height: 24
                        anchors.right: parent.right
                        anchors.rightMargin: 5
                        anchors.verticalCenter: parent.verticalCenter
                        visible: searchField.text !== ""
                        background: Rectangle { color: "transparent"; radius: 12 }
                        contentItem: Text {
                            text: "✕"; font.pixelSize: 14; color: "#666666"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            searchField.text = ""
                            patientsItem.filteredPatients = patientsItem.allPatients
                        }
                    }
                }

                Button {
                    text: "Обновить"
                    implicitWidth: 100
                    implicitHeight: 35
                    font.pixelSize: 14
                    background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 8 }
                    onClicked: patientsItem.loadPatients()
                }

                Button {
                    text: "Назад"
                    implicitWidth: 100
                    implicitHeight: 35
                    font.pixelSize: 14
                    background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 8 }
                    onClicked: {
                        nurseStackView.pop(null)
                        nurseStackView.push(departmentsPage)
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
                radius: 12

                ListView {
                    id: patientModel
                    anchors.fill: parent
                    anchors.margins: 10
                    clip: true
                    highlightFollowsCurrentItem: false
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded; width: 10 }
                    model: patientsItem.filteredPatients

                    header: Rectangle {
                        width: patientModel.width - 10
                        height: 35
                        color: "#fff0f5"
                        radius: 8
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10
                            Text { text: "ФИО"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14; color: "#4a4a4a" }
                            Text { text: "Полис"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14; color: "#4a4a4a" }
                            Text { text: "Срок"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14; color: "#4a4a4a" }
                            Text { text: "Болезнь"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14; color: "#4a4a4a" }
                            Text { text: "Отделение"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14; color: "#4a4a4a" }
                            Text { text: "Палата"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14; color: "#4a4a4a" }
                        }
                    }

                    delegate: Rectangle {
                        width: patientModel.width - 10
                        height: 40
                        opacity: modelData.is_discharged ? 0.5 : 1.0 // Выписанные серым

                        color: patientModel.currentIndex === index ? "#e3f2fd" : (index % 2 === 0 ? "#ffffff" : "#fcfcfc")
                        border.color: "#eeeeee"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Text { text: modelData.full_name !== "" ? modelData.full_name : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text { text: modelData.policy !== "" ? modelData.policy : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text { text: modelData.pregnancy_period !== "" ? modelData.pregnancy_period : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text {
                                text: modelData.disease ? "Да" : "Нет"
                                Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14
                            }
                            Text { text: modelData.department !== "" ? modelData.department : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text { text: modelData.chamber !== "" ? modelData.chamber : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            onClicked: patientModel.currentIndex = index
                        }
                    }
                }

                Text {
                    text: searchField.text === "" ? "В базе пока нет пациентов 🧸" : "Нет таких пациентов с ФИО"
                    anchors.centerIn: parent
                    color: "#999999"
                    visible: patientModel.count === 0
                    font.pixelSize: 16
                }
            }
        }
    }
}