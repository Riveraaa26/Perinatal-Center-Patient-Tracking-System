import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PerinatalCenter 1.0

Item {
    id: headDoctorPage

    signal patientDataChanged()

    property string currentUserLogin: ""
    property string currentUserFullName: ""
    property int currentEmployeeId: -1
    property string currentTab: "history"

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
            text: "👩‍⚕️"
            font.pixelSize: 32
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                id: roleText
                text: "Заведующая отделением"
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
        text: headDoctorPage.currentUserFullName
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
                    headDoctorPage.currentTab = "history"
                    headDoctorStackView.pop(null)
                    headDoctorStackView.push(historyPage)
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
                    headDoctorPage.currentTab = "departments"
                    headDoctorStackView.pop(null)
                    headDoctorStackView.push(departmentsPage)
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
                    headDoctorPage.currentTab = "patients"
                    headDoctorStackView.pop(null)
                    headDoctorStackView.push(patientsPage)
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
            id: headDoctorStackView
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

            Connections {
                target: headDoctorPage
                function onPatientDataChanged() {
                    historyItem.loadHistory()
                }
            }

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
                        headDoctorPage.currentTab = "departments"
                        headDoctorStackView.pop(null)
                        headDoctorStackView.push(departmentsPage)
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
                    text: "История переводов пуста 👩‍⚕️"
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

            Component.onCompleted: deptModel.model = Yadro.getDepartments()

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
                            acceptedButtons: Qt.LeftButton
                            onClicked: deptModel.currentIndex = index
                            onDoubleClicked: headDoctorStackView.push(mapPage, {
                                "deptId": parseInt(modelData.id),
                                "deptName": modelData.name
                            })
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
                text: "🧸 " + mapItem.deptName
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
                    onClicked: headDoctorStackView.pop()
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
                                onClicked: headDoctorStackView.push(chamberPatientsPage, {
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
    // 7. СПИСОК ПАЦИЕНТОВ ПАЛАТЫ
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
                    onClicked: headDoctorStackView.pop()
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
                        color: index % 2 === 0 ? "#ffffff" : "#fcfcfc"
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
                                text: modelData.disease ? "Да" : "—"
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
    // 8. СТРАНИЦА ВСЕХ ПАЦИЕНТОВ
    // ==========================================
    Component {
        id: patientsPage

        Item {
            id: patientsItem

            property var allPatients: []
            property var filteredPatients: []

            property int selectedPatientId: -1
            property string selectedPatientName: ""
            property bool selectedPatientIsDisease: false
            property string selectedPatientDepartment: ""
            property string selectedPatientChamber: ""
            property bool selectedPatientIsDischarged: false

            Connections {
                target: headDoctorPage
                function onPatientDataChanged() {
                    patientsItem.loadPatients()
                }
            }

            Component.onCompleted: loadPatients()

            function loadPatients() {
                allPatients = Yadro.getPatients()
                patientsItem.filteredPatients = allPatients
                searchField.text = ""
                patientsItem.selectedPatientId = -1
                patientsItem.selectedPatientName = ""
                patientsItem.selectedPatientIsDisease = false
                patientsItem.selectedPatientDepartment = ""
                patientsItem.selectedPatientChamber = ""
                patientsItem.selectedPatientIsDischarged = false

                if (allPatients.length > 0) {
                    patientModel.currentIndex = 0
                    let pat = allPatients[0]
                    patientsItem.selectedPatientId = parseInt(pat.id)
                    patientsItem.selectedPatientName = pat.full_name
                    patientsItem.selectedPatientIsDisease = !!pat.disease
                    patientsItem.selectedPatientDepartment = pat.department || ""
                    patientsItem.selectedPatientChamber = pat.chamber || ""
                    patientsItem.selectedPatientIsDischarged = !!pat.is_discharged
                } else {
                    patientModel.currentIndex = -1
                }
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
                text: "🧕 Пациенты"
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
                        headDoctorPage.currentTab = "departments"
                        headDoctorStackView.pop(null)
                        headDoctorStackView.push(departmentsPage)
                    }
                }
            }

            Rectangle {
                id: tableContainer
                anchors.top: pageTitle.bottom
                anchors.topMargin: 15
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.bottom: bottomPanel.top
                anchors.bottomMargin: 15

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

                    onCurrentIndexChanged: {
                        if (currentIndex >= 0 && patientsItem.filteredPatients.length > currentIndex) {
                            let pat = patientsItem.filteredPatients[currentIndex]
                            patientsItem.selectedPatientId = parseInt(pat.id)
                            patientsItem.selectedPatientName = pat.full_name
                            patientsItem.selectedPatientIsDisease = !!pat.disease
                            patientsItem.selectedPatientDepartment = pat.department || ""
                            patientsItem.selectedPatientChamber = pat.chamber || ""
                            patientsItem.selectedPatientIsDischarged = !!pat.is_discharged
                        } else {
                            patientsItem.selectedPatientId = -1
                            patientsItem.selectedPatientName = ""
                            patientsItem.selectedPatientIsDisease = false
                            patientsItem.selectedPatientDepartment = ""
                            patientsItem.selectedPatientChamber = ""
                            patientsItem.selectedPatientIsDischarged = false
                        }
                    }

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

                        // Выписанные — серым (полупрозрачные)
                        opacity: modelData.is_discharged ? 0.5 : 1.0

                        color: patientModel.currentIndex === index
                               ? "#e3f2fd"
                               : (index % 2 === 0 ? "#ffffff" : "#fcfcfc")
                        border.color: "#eeeeee"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            // Обычный шрифт (без bold)
                            Text { text: modelData.full_name !== "" ? modelData.full_name : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text { text: modelData.policy !== "" ? modelData.policy : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text { text: modelData.pregnancy_period !== "" ? modelData.pregnancy_period : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text {
                                text: modelData.disease ? "Да" : "—"
                                Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14
                            }
                            Text { text: modelData.department !== "" ? modelData.department : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text { text: modelData.chamber !== "" ? modelData.chamber : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton

                            onClicked: {
                                patientModel.currentIndex = index
                            }

                            onDoubleClicked: {
                                patientModel.currentIndex = index
                                transferPopup.openFor(
                                    parseInt(modelData.id),
                                    modelData.full_name,
                                    !!modelData.disease
                                )
                            }
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

            RowLayout {
                id: bottomPanel
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                anchors.right: parent.right
                anchors.rightMargin: 20
                spacing: 15

                Button {
                    text: "➕ Добавить пациентку"
                    implicitWidth: 180
                    implicitHeight: 40
                    font.pixelSize: 15
                    background: Rectangle { color: "#e8f5e9"; border.color: "#a5d6a7"; radius: 10 }
                    onClicked: {
                        createPatientName.text = ""
                        createPatientSourName.text = ""
                        createPatientPolicy.text = ""
                        createPatientPregnancy.text = ""
                        createPatientDisease.checked = false
                        createPatientErrorLabel.visible = false
                        createPatientPopup.open()
                    }
                }

                Button {
                    text: "🚚 Перевести в палату"
                    implicitWidth: 180
                    implicitHeight: 40
                    font.pixelSize: 15
                    enabled: patientsItem.selectedPatientId !== -1
                    background: Rectangle {
                        color: enabled ? (parent.down ? "#ffe082" : (parent.hovered ? "#fff8e1" : "#ffffff")) : "#f5f5f5"
                        border.color: enabled ? "#ffcc80" : "#e0e0e0"
                        radius: 10
                    }
                    onClicked: {
                        transferPopup.openFor(
                            patientsItem.selectedPatientId,
                            patientsItem.selectedPatientName,
                            patientsItem.selectedPatientIsDisease
                        )
                    }
                }

                Button {
                    text: "🏠 Выписать пациентку"
                    implicitWidth: 180
                    implicitHeight: 40
                    font.pixelSize: 15
                    enabled: patientsItem.selectedPatientId !== -1
                             && !patientsItem.selectedPatientIsDischarged
                             && patientsItem.selectedPatientDepartment !== ""
                             && patientsItem.selectedPatientChamber !== ""
                    opacity: enabled ? 1.0 : 0.45
                    background: Rectangle {
                        color: enabled ? (parent.down ? "#ffcdd2" : (parent.hovered ? "#ffebee" : "#ffffff")) : "#f5f5f5"
                        border.color: enabled ? "#ef9a9a" : "#e0e0e0"
                        radius: 10
                    }

                    onClicked: {
                        const err = Yadro.dischargePatient(patientsItem.selectedPatientId, headDoctorPage.currentEmployeeId)
                        if (err.length === 0) {
                            headDoctorPage.patientDataChanged()
                        } else {
                            console.error(err)
                        }
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }
    }

    // ==========================================
    // 9. ПОПАП ПЕРЕВОДА ПАЦИЕНТКИ
    // ==========================================
    Popup {
        id: transferPopup
        width: 460
        implicitHeight: Math.min(transferLayout.implicitHeight + 50, headDoctorPage.height - 40)
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle { color: "#ffffff"; border.color: accentColor; border.width: 2; radius: 16 }

        property int patientId: -1
        property bool patientIsDisease: false
        property var departmentsData: []
        property var chambersData: []

        function openFor(pid, fullName, isDisease) {
            patientId = pid
            patientIsDisease = isDisease

            transferPatientLabel.text = fullName

            departmentsData = Yadro.getDepartments()
            deptCombo.model = departmentsData
            deptCombo.currentIndex = -1

            chambersData = []
            chamberCombo.model = []
            chamberCombo.currentIndex = -1

            transferErrorLabel.visible = false
            transferErrorLabel.text = ""

            open()
        }

        function loadChambers() {
            chambersData = []
            chamberCombo.model = []
            chamberCombo.currentIndex = -1

            if (deptCombo.currentIndex < 0 || departmentsData.length === 0)
                return

            const dept = departmentsData[deptCombo.currentIndex]
            const allChambers = Yadro.getChambersByDepartment(parseInt(dept.id))

            const filtered = []
            for (let i = 0; i < allChambers.length; i++) {
                const ch = allChambers[i]
                const isDiseaseChamber = !!ch.disease

                if (isDiseaseChamber !== transferPopup.patientIsDisease)
                    continue

                if (parseInt(ch.free_places) <= 0)
                    continue

                filtered.push(ch)
            }

            chambersData = filtered
            chamberCombo.model = filtered
            chamberCombo.currentIndex = -1
        }

        ColumnLayout {
            id: transferLayout
            x: 20
            y: 20
            width: parent.width - 40
            spacing: 12

            Text {
                text: "🚚 Перевод пациентки"
                font.pixelSize: 20
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 5
            }

            Text {
                id: transferPatientLabel
                text: ""
                font.pixelSize: 14
                color: accentHover
                font.bold: true
                Layout.fillWidth: true
            }

            Text {
                text: transferPopup.patientIsDisease
                      ? "⚠ Пациентка с болезнью — доступны только изоляторы"
                      : "✅ Пациентка здорова — доступны только обычные палаты"
                font.pixelSize: 12
                color: transferPopup.patientIsDisease ? "#b91c1c" : "#15803d"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.bottomMargin: 5
            }

            Text { text: "Отделение"; font.pixelSize: 12; color: "#666" }
            ComboBox {
                id: deptCombo
                Layout.fillWidth: true
                implicitHeight: 40
                textRole: "name"
                model: []

                delegate: ItemDelegate {
                    width: deptCombo.width
                    contentItem: Text {
                        text: modelData.name
                        font.pixelSize: 14
                        verticalAlignment: Text.AlignVCenter
                    }
                    highlighted: deptCombo.highlightedIndex === index
                }

                contentItem: Text {
                    leftPadding: 10
                    text: deptCombo.currentIndex >= 0 && deptCombo.model.length > 0
                          ? deptCombo.model[deptCombo.currentIndex].name
                          : "— выберите отделение —"
                    color: deptCombo.currentIndex >= 0 ? "#333333" : "#999999"
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                onCurrentIndexChanged: transferPopup.loadChambers()
            }

            Text { text: "Палата (только свободные)"; font.pixelSize: 12; color: "#666" }
            ComboBox {
                id: chamberCombo
                Layout.fillWidth: true
                implicitHeight: 40
                model: transferPopup.chambersData

                delegate: ItemDelegate {
                    width: chamberCombo.width
                    contentItem: Text {
                        text: "Палата " + modelData.number
                              + "  •  " + (modelData.disease ? "Изолятор" : "Обычная")
                              + "  •  свободно " + modelData.free_places
                              + "/" + modelData.capacity
                        font.pixelSize: 14
                        verticalAlignment: Text.AlignVCenter
                    }
                    highlighted: chamberCombo.highlightedIndex === index
                }

                contentItem: Text {
                    leftPadding: 10
                    text: chamberCombo.currentIndex >= 0 && transferPopup.chambersData.length > 0
                          ? ("Палата " + transferPopup.chambersData[chamberCombo.currentIndex].number
                             + "  (свободно " + transferPopup.chambersData[chamberCombo.currentIndex].free_places + ")")
                          : "— выберите палату —"
                    color: "#333333"
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }

            Text {
                id: transferErrorLabel
                color: "red"
                font.pixelSize: 13
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                visible: false
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 10
                spacing: 10

                Button {
                    text: "Отмена"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 10 }
                    onClicked: transferPopup.close()
                }

                Button {
                    text: "Перевести"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    enabled: deptCombo.currentIndex >= 0
                             && chamberCombo.currentIndex >= 0
                             && transferPopup.chambersData.length > 0
                    background: Rectangle {
                        color: enabled ? (parent.down ? "#a5d6a7" : (parent.hovered ? "#c8e6c9" : "#e8f5e9")) : "#f5f5f5"
                        border.color: enabled ? "#81c784" : "#e0e0e0"
                        radius: 10
                    }

                    onClicked: {
                        transferErrorLabel.visible = false

                        const dept = transferPopup.departmentsData[deptCombo.currentIndex]
                        const ch = transferPopup.chambersData[chamberCombo.currentIndex]

                        const err = Yadro.transferPatient(
                            transferPopup.patientId,
                            parseInt(dept.id),
                            parseInt(ch.number),
                            headDoctorPage.currentEmployeeId
                        )

                        if (err.length === 0) {
                            transferPopup.close()
                            headDoctorPage.patientDataChanged()
                        } else {
                            transferErrorLabel.text = err
                            transferErrorLabel.visible = true
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // 10. ПОПАП ДОБАВЛЕНИЯ ПАЦИЕНТКИ
    // ==========================================
    Popup {
        id: createPatientPopup
        width: 400
        implicitHeight: Math.min(contentLayout.implicitHeight + 50, headDoctorPage.height - 40)
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle { color: "#ffffff"; border.color: accentColor; border.width: 2; radius: 16 }

        Flickable {
            id: popupFlick
            anchors.fill: parent
            anchors.margins: 10
            clip: true
            contentWidth: width
            contentHeight: contentLayout.implicitHeight + 40
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            ColumnLayout {
                id: contentLayout
                x: 20
                y: 20
                width: parent.width - 40
                spacing: 15

                Text {
                    text: "🎀 Новая пациентка"
                    font.pixelSize: 20
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 10
                }

                Text { text: "Имя"; font.pixelSize: 12; color: "#666" }
                TextField {
                    id: createPatientName
                    Layout.fillWidth: true
                    implicitHeight: 40
                    font.pixelSize: 14
                    leftPadding: 10
                    background: Rectangle { border.color: "#cccccc"; radius: 8 }
                    onTextChanged: createPatientErrorLabel.visible = false
                }

                Text { text: "Фамилия"; font.pixelSize: 12; color: "#666" }
                TextField {
                    id: createPatientSourName
                    Layout.fillWidth: true
                    implicitHeight: 40
                    font.pixelSize: 14
                    leftPadding: 10
                    background: Rectangle { border.color: "#cccccc"; radius: 8 }
                    onTextChanged: createPatientErrorLabel.visible = false
                }

                Text { text: "Полис"; font.pixelSize: 12; color: "#666" }
                TextField {
                    id: createPatientPolicy
                    Layout.fillWidth: true
                    implicitHeight: 40
                    font.pixelSize: 14
                    leftPadding: 10
                    background: Rectangle { border.color: "#cccccc"; radius: 8 }
                    onTextChanged: createPatientErrorLabel.visible = false
                }

                Text { text: "Срок беременности"; font.pixelSize: 12; color: "#666" }
                TextField {
                    id: createPatientPregnancy
                    Layout.fillWidth: true
                    implicitHeight: 40
                    font.pixelSize: 14
                    leftPadding: 10
                    background: Rectangle { border.color: "#cccccc"; radius: 8 }
                    onTextChanged: createPatientErrorLabel.visible = false
                }

                CheckBox {
                    id: createPatientDisease
                    text: "Болезнь (для больных)"
                    font.pixelSize: 14
                    onCheckedChanged: createPatientErrorLabel.visible = false
                }

                Text {
                    id: createPatientErrorLabel
                    color: "red"
                    font.pixelSize: 13
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    visible: false
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    spacing: 10

                    Button {
                        text: "Отмена"
                        Layout.fillWidth: true
                        implicitHeight: 40
                        background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 10 }
                        onClicked: createPatientPopup.close()
                    }

                    Button {
                        text: "Сохранить"
                        Layout.fillWidth: true
                        implicitHeight: 40
                        enabled: createPatientName.text.trim() !== ""
                                 && createPatientSourName.text.trim() !== ""
                                 && createPatientPolicy.text.trim() !== ""
                                 && createPatientPregnancy.text.trim() !== ""
                        background: Rectangle {
                            color: enabled ? (parent.down ? "#a5d6a7" : (parent.hovered ? "#c8e6c9" : "#e8f5e9")) : "#f5f5f5"
                            border.color: enabled ? "#81c784" : "#e0e0e0"
                            radius: 10
                        }

                        onClicked: {
                            createPatientErrorLabel.visible = false

                            const err = Yadro.createPatient(
                                createPatientName.text,
                                createPatientSourName.text,
                                createPatientPolicy.text,
                                createPatientPregnancy.text,
                                createPatientDisease.checked
                            )

                            if (err.length === 0) {
                                createPatientPopup.close()
                                headDoctorPage.patientDataChanged()
                            } else {
                                createPatientErrorLabel.text = err
                                createPatientErrorLabel.visible = true
                            }
                        }
                    }
                }
            }
        }
    }
}