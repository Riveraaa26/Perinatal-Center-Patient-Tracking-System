import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PerinatalCenter 1.0

Item {
    id: doctorPage

    Label {
        id: registrationNotice
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        z: 2
        visible: noticeTimer.running
        text: "Пациентка успешно зарегистрирована"
    }
    Timer { id: noticeTimer; interval: 4000 }
    property string currentUserLogin: ""
    property string currentUserFullName: ""
    property string currentUserRole: "Врач акушер-гинеколог"
    property bool isHead: false
    property string currentTab: "departments"

    // ==========================================
    // 1. ШАПКА
    // ==========================================
    Text {
        id: roleText
        text: doctorPage.currentUserRole
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
        text: doctorPage.currentUserFullName
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
        onClicked: { Yadro.logoutUser(); stackView.pop() }
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
                    doctorPage.currentTab = "departments"
                    doctorStackView.pop(null)
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
                    doctorPage.currentTab = "patients"
                    doctorStackView.pop(null)
                    doctorStackView.push(patientsPage)
                }
            }

            Button {
                text: "Статистика мест"
                Layout.fillWidth: true
                implicitHeight: 40
                onClicked: statisticsPopup.showStats()
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
            id: doctorStackView
            anchors.fill: parent

            initialItem: Item {
                id: deptPage
                function refresh() {
                    const rows = Yadro.getDepartments()
                    if (!Yadro.readError || Yadro.readError.includes("прав")) deptModel.model = rows
                }
                Component.onCompleted: refresh()
                StackView.onActivated: refresh()
                Timer { interval: 8000; repeat: true; running: deptPage.visible; onTriggered: deptPage.refresh() }

                Text {
                    id: pageTitle
                    text: !Yadro.readError && deptModel.model && deptModel.model.every(d => d.free_places === 0) ? "Отделения — свободных мест нет" : "Отделения"
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
                                Text { text: "Изоляторов"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14 }
                                Text { text: "Свободно мест"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14 }
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
                                Text { text: modelData.free_places; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14 }
                            }

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton
                                onClicked: deptModel.currentIndex = index
                                onDoubleClicked: doctorStackView.push(mapPage, {
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
    // 4. КАРТА ПАЛАТ
    // ==========================================
    Component {
        id: mapPage

        Item {
            id: mapItem
            property int deptId: -1
            property string deptName: ""
            property var chambers: []

            Component.onCompleted: loadChambers()
            function loadChambers() {
                const result = Yadro.getChambersByDepartment(deptId)
                if (!Yadro.readError || Yadro.readError.includes("прав")) chambers = result
            }
            Timer { interval: 8000; repeat: true; running: mapItem.visible; onTriggered: mapItem.loadChambers() }

            Text {
                id: mapTitle
                text: mapItem.deptName
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
                    onClicked: mapItem.loadChambers()
                }

                Button {
                    text: "Назад"
                    implicitWidth: 100
                    implicitHeight: 35
                    font.pixelSize: 14
                    onClicked: doctorStackView.pop()
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
                radius: 8

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
                            radius: 8
                            color: modelData.disease && modelData.kind !== "operating" ? "#fff3cd" : (modelData.free_places > 0 ? "#dcfce7" : "#fde2e1")
                            border.color: modelData.free_places > 0 ? "#16a34a" : "#d9534f"
                            border.width: 2

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 10
                                Text { text: "Палата " + modelData.number; font.pixelSize: 18; font.bold: true; color: "#333333"; Layout.fillWidth: true }
                                Text { text: "Тип: " + (modelData.kind === "operating" ? "Операционная" : modelData.disease ? "Изолятор" : "Обычная"); font.pixelSize: 14; color: "#555555"; Layout.fillWidth: true }
                                Text {
                                    text: "Свободно: " + modelData.free_places + " / " + modelData.capacity
                                    font.pixelSize: 14; font.bold: true
                                    color: modelData.free_places > 0 ? "#15803d" : "#b91c1c"
                                    Layout.fillWidth: true
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: doctorStackView.push(chamberPatientsPage, {
                                    "deptId": mapItem.deptId,
                                    "chamberNumber": parseInt(modelData.number),
                                    "chamberName": "Палата " + modelData.number
                                })
                            }
                        }
                    }
                }

                Text {
                    text: "В этом отделении пока нет палат"
                    anchors.centerIn: parent
                    color: "#999999"
                    visible: mapItem.chambers.length === 0
                }
            }
        }
    }

    // ==========================================
    // 5. СПИСОК ПАЦИЕНТОВ ПАЛАТЫ
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
            Timer { interval: 8000; repeat: true; running: chamberPatItem.visible; onTriggered: chamberPatItem.loadPatients() }

            Text {
                id: pageTitle
                text: chamberPatItem.chamberName
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
                    onClicked: chamberPatItem.loadPatients()
                }

                Button {
                    text: "Назад"
                    implicitWidth: 100
                    implicitHeight: 35
                    font.pixelSize: 14
                    onClicked: doctorStackView.pop()
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
                        color: "#f0f0f0"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10
                            Text { text: "ФИО"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 2; font.pixelSize: 14 }
                            Text { text: "Полис"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14 }
                            Text { text: "Срок"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14 }
                            Text { text: "Болезнь"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; font.pixelSize: 14 }
                        }
                    }

                    delegate: Rectangle {
                        width: patientListModel.width - 10
                        height: 40
                        color: index % 2 === 0 ? "#ffffff" : "#f9f9f9"
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
                    text: "В этой палате пока нет пациентов"
                    anchors.centerIn: parent
                    color: "#999999"
                    visible: patientListModel.count === 0
                    font.pixelSize: 14
                }
            }
        }
    }

    // ==========================================
    // 6. СТРАНИЦА ВСЕХ ПАЦИЕНТОВ + ДВОЙНОЙ КЛИК → ПЕРЕВОД
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
            property bool selectedPatientDischarged: false
            property string selectedPatientDepartment: ""

            Component.onCompleted: loadPatients()

            function loadPatients() {
                allPatients = Yadro.getPatients()
                patientsItem.filteredPatients = allPatients
                searchField.text = ""
                patientsItem.selectedPatientId = -1
                patientsItem.selectedPatientName = ""
                patientsItem.selectedPatientIsDisease = false
                patientsItem.selectedPatientDischarged = false
                patientsItem.selectedPatientDepartment = ""
            }

            // Периодически запрашиваем новые данные, если другие сотрудники изменили размещение.
            function refreshPatients() {
                allPatients = Yadro.getPatients()
                filterPatients()
                for (let i = 0; i < allPatients.length; ++i) {
                    if (allPatients[i].id === patientsItem.selectedPatientId) {
                        patientsItem.selectedPatientDischarged = !!allPatients[i].discharged
                        patientsItem.selectedPatientDepartment = allPatients[i].departmentKind || ""
                        return
                    }
                }
                patientsItem.selectedPatientId = -1
            }
            Timer {
                interval: 8000
                repeat: true
                running: patientsItem.visible && !transferPopup.visible && !createPatientPopup.visible
                onTriggered: patientsItem.refreshPatients()
            }

            function findPolicy(policy) { refreshPatients(); searchField.text = policy }
            function filterPatients() {
                let query = searchField.text.trim().toLowerCase()
                if (query === "") {
                    patientsItem.filteredPatients = patientsItem.allPatients
                    return
                }
                let result = []
                for (let i = 0; i < patientsItem.allPatients.length; i++) {
                    let pat = patientsItem.allPatients[i]
                    if ((pat.full_name && pat.full_name.toLowerCase().includes(query)) || String(pat.policy).includes(query))
                        result.push(pat)
                }
                patientsItem.filteredPatients = result
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
                    radius: 4

                    TextField {
                        id: searchField
                        anchors.fill: parent
                        placeholderText: "Поиск по ФИО или полису..."
                        font.pixelSize: 14
                        leftPadding: 10
                        rightPadding: 30
                        background: null
                        onTextChanged: { patientsItem.selectedPatientId = -1; patientsItem.filterPatients() }
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
                    onClicked: patientsItem.loadPatients()
                }

                Button {
                    text: "Назад"
                    implicitWidth: 100
                    implicitHeight: 35
                    font.pixelSize: 14
                    onClicked: {
                        doctorPage.currentTab = "departments"
                        doctorStackView.pop(null)
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
                radius: 8

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
                        color: patientsItem.selectedPatientId === modelData.id
                               ? "#cce5ff"
                               : (index % 2 === 0 ? "#ffffff" : "#f9f9f9")
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
                                text: modelData.disease ? "Да" : "—"
                                Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14
                            }
                            Text { text: modelData.discharged ? "Выписана" : (modelData.department !== "" ? modelData.department : "—"); Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text { text: modelData.chamber !== "" ? modelData.chamber : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton

                            onClicked: {
                                patientModel.currentIndex = index
                                patientsItem.selectedPatientId = parseInt(modelData.id)
                                patientsItem.selectedPatientName = modelData.full_name
                                patientsItem.selectedPatientIsDisease = !!modelData.disease
                                patientsItem.selectedPatientDischarged = !!modelData.discharged
                                patientsItem.selectedPatientDepartment = modelData.departmentKind || ""
                            }

                            onDoubleClicked: {
                                patientModel.currentIndex = index
                                patientsItem.selectedPatientId = parseInt(modelData.id)
                                patientsItem.selectedPatientName = modelData.full_name
                                patientsItem.selectedPatientIsDisease = !!modelData.disease
                                patientsItem.selectedPatientDischarged = !!modelData.discharged
                                patientsItem.selectedPatientDepartment = modelData.departmentKind || ""

                                if (!modelData.discharged) {
                                    transferPopup.openFor(
                                        parseInt(modelData.id),
                                        modelData.full_name,
                                        !!modelData.disease
                                    )
                                }
                            }
                        }
                    }
                }

                Text {
                    text: searchField.text === "" ? "В базе пока нет пациентов" : "Нет таких пациентов с ФИО"
                    anchors.centerIn: parent
                    color: "#999999"
                    visible: patientModel.count === 0
                    font.pixelSize: 14
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
                    text: "Добавить пациентку"
                    visible: doctorPage.isHead
                    implicitWidth: 180
                    implicitHeight: 40
                    font.pixelSize: 15
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
                    text: "В палату"
                    implicitWidth: 100
                    implicitHeight: 40
                    font.pixelSize: 15
                    enabled: patientsItem.selectedPatientId !== -1 && !patientsItem.selectedPatientDischarged
                    onClicked: {
                        transferPopup.openFor(
                            patientsItem.selectedPatientId,
                            patientsItem.selectedPatientName,
                            patientsItem.selectedPatientIsDisease
                        )
                    }
                }

                Button {
                    text: "В операционную"
                    enabled: patientsItem.selectedPatientId > 0 && !patientsItem.selectedPatientDischarged
                    onClicked: transferPopup.openFor(patientsItem.selectedPatientId, patientsItem.selectedPatientName, patientsItem.selectedPatientIsDisease, true)
                }
                Button {
                    text: "История"
                    implicitWidth: 100
                    implicitHeight: 40
                    enabled: patientsItem.selectedPatientId > 0
                    onClicked: historyPopup.openFor(patientsItem.selectedPatientId, patientsItem.selectedPatientName)
                }
                Button {
                    text: "Выписать"
                    visible: doctorPage.isHead
                    implicitWidth: 110
                    implicitHeight: 40
                    enabled: patientsItem.selectedPatientId > 0 && !patientsItem.selectedPatientDischarged
                             && patientsItem.selectedPatientDepartment === "postpartum"
                    onClicked: {
                        dischargeDialog.expectedVersion = patientsItem.allPatients.find(p => p.id === patientsItem.selectedPatientId).placementVersion
                        dischargeDialog.patientId = patientsItem.selectedPatientId
                        dischargeDialog.patientName = patientsItem.selectedPatientName
                        dischargeRecommendations.text = ""
                        dischargeDay.text = Qt.formatDate(new Date(), "yyyy-MM-dd")
                        dischargeDialog.open()
                    }
                }
                Item { Layout.fillWidth: true }
            }
        }
    }

    // ==========================================
    // 7. ПОПАП ПЕРЕВОДА ПАЦИЕНТКИ
    // ==========================================
    Dialog {
        id: dischargeDialog
        property int expectedVersion: -1
        property int patientId: -1
        property string patientName: ""
        title: "Подтвердить выписку"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: 410
        contentItem: ColumnLayout {
            width: 370
            spacing: 10
            Text {
                text: "Выписать пациентку «" + dischargeDialog.patientName + "»? Место освободится, карта останется в истории."
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                font.pixelSize: 14
            }
            Text { text: "Дата выписки (ГГГГ-ММ-ДД)"; font.pixelSize: 12; color: "#666" }
            TextField { id: dischargeDay; Layout.fillWidth: true }
            TextArea {
                id: dischargeRecommendations
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                wrapMode: TextEdit.Wrap
                placeholderText: "Рекомендации при выписке"
            }
        }
        onAccepted: {
            const err = Yadro.dischargePatient(patientId, dischargeRecommendations.text, dischargeDay.text, expectedVersion)
            if (err.length > 0) {
                actionError.message = err
                actionError.open()
            } else {
                doctorStackView.pop(null)
                doctorStackView.push(patientsPage)
            }
        }
    }

    Dialog {
        id: actionError
        property alias message: actionErrorText.text
        title: "Не удалось выполнить действие"
        standardButtons: Dialog.Ok
        modal: true
        anchors.centerIn: parent
        width: 420
        contentItem: Text {
            id: actionErrorText
            wrapMode: Text.WordWrap
            width: 380
        }
    }

    Popup {
        id: historyPopup
        width: Math.min(560, doctorPage.width-40)
        height: Math.min(450, doctorPage.height-40)
        anchors.centerIn: parent
        modal: true
        focus: true
        property var events: []
        property string patientName: ""
        function openFor(patientId, name) {
            patientName = name
            events = Yadro.getPatientHistory(patientId)
            open()
        }
        background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 8 }
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 10
            Text { text: "История: " + historyPopup.patientName; font.pixelSize: 18; font.bold: true; Layout.fillWidth: true; elide: Text.ElideRight }
            ListView {
                Layout.fillWidth: true; Layout.fillHeight: true
                clip: true
                model: historyPopup.events
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                delegate: Rectangle {
                    width: ListView.view.width; height: 62
                    color: index % 2 === 0 ? "#f4f7f6" : "#ffffff"
                    Column {
                        anchors.fill: parent; anchors.margins: 6; spacing: 4
                        Text { text: modelData.date + " — " + modelData.action; font.pixelSize: 13; font.bold: true }
                        Text { text: modelData.action === "Выписка" ? ("Дата выписки: " + modelData.effectiveDate + " · Сотрудник: " + modelData.employee + (modelData.recommendations ? " · " + modelData.recommendations : ""))
                                      : (modelData.department + ", палата " + modelData.chamber + " · " + modelData.employee)
                               font.pixelSize: 12; elide: Text.ElideRight; width: parent.width }
                    }
                }
            }
            Button { text: "Закрыть"; Layout.alignment: Qt.AlignRight; onClicked: historyPopup.close() }
        }
    }

    Popup {
        id: transferPopup
        width: 460
        implicitHeight: Math.min(transferLayout.implicitHeight + 50, doctorPage.height - 40)
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 8 }

        property int expectedVersion: -1
        property int patientId: -1
        property bool patientIsDisease: false
        property var departmentsData: []
        property var chambersData: []

        property bool operating: false
        function openFor(pid, fullName, isDisease, operatingOnly) {
            const patient = doctorStackView.currentItem.allPatients.find(p => p.id === pid)
            if (!patient) return
            expectedVersion = patient.placementVersion
            patientId = pid
            operating = !!operatingOnly
            patientIsDisease = isDisease

            transferPatientLabel.text = fullName

            departmentsData = Yadro.getDepartments().filter(d => operating === (d.kind === "operating"))
            deptCombo.model = departmentsData
            deptCombo.currentIndex = -1

            chambersData = []
            chamberCombo.model = []
            chamberCombo.currentIndex = -1

            transferErrorLabel.visible = false
            transferErrorLabel.text = ""

            if (departmentsData.length) { deptCombo.currentIndex = 0; loadChambers() }
            if (!departmentsData.length) {
                transferErrorLabel.text = operating ? "Нет настроенных операционных." : "Нет отделений."
                transferErrorLabel.visible = true
            }
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

                if (!operating && isDiseaseChamber !== transferPopup.patientIsDisease)
                    continue

                if (parseInt(ch.free_places) <= 0)
                    continue

                filtered.push(ch)
            }

            chambersData = filtered
            chamberCombo.model = filtered
            chamberCombo.currentIndex = filtered.length ? 0 : -1
            transferErrorLabel.text = Yadro.readError || (operating ? "Все операционные в отделении заняты." : "Подходящих свободных мест в отделении нет.")
            transferErrorLabel.visible = filtered.length === 0
        }

        ColumnLayout {
            id: transferLayout
            x: 20
            y: 20
            width: parent.width - 40
            spacing: 12

            Text {
                text: transferPopup.operating ? "Перевод в операционную" : "Перевод пациентки"
                font.pixelSize: 20
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 5
            }

            Text {
                id: transferPatientLabel
                text: ""
                font.pixelSize: 14
                color: "#333333"
                font.bold: true
                Layout.fillWidth: true
            }

            Text {
                text: transferPopup.operating ? "Выберите свободную операционную и подтвердите перевод" : transferPopup.patientIsDisease
                      ? "⚠ Пациентка с болезнью — доступны только изоляторы"
                      : "Пациентка здорова — доступны только обычные палаты"
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
                              + "  •  " + (modelData.kind === "operating" ? "Операционная" : modelData.disease ? "Изолятор" : "Обычная")
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
                    onClicked: transferPopup.close()
                }

                Button {
                    id: transferSave
                    text: "Перевести"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    enabled: deptCombo.currentIndex >= 0
                             && chamberCombo.currentIndex >= 0
                             && transferPopup.chambersData.length > 0

                    onClicked: {
                        transferErrorLabel.visible = false

                        const dept = transferPopup.departmentsData[deptCombo.currentIndex]
                        const ch = transferPopup.chambersData[chamberCombo.currentIndex]

                        const err = Yadro.transferPatient(
                            transferPopup.patientId,
                            parseInt(dept.id),
                            parseInt(ch.number), transferPopup.expectedVersion
                        )

                        if (err.length === 0) {
                            transferPopup.close()
                            if (doctorStackView.currentItem.refreshPatients) doctorStackView.currentItem.refreshPatients()
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
    // 8. ПОПАП ДОБАВЛЕНИЯ ПАЦИЕНТКИ
    // ==========================================
    Popup {
        id: createPatientPopup
        width: 400
        implicitHeight: Math.min(contentLayout.implicitHeight + 50, doctorPage.height - 40)
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 8 }

        Flickable {
            id: popupFlick
            anchors.fill: parent
            anchors.margins: 5
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
                    text: "Новая пациентка"
                    font.pixelSize: 20
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 10
                }

                Text { text: "Имя"; font.pixelSize: 12; color: "#666" }
                TextField {
                    id: createPatientName
                    palette.placeholderText: "#b91c1c"; placeholderText: "Обязательное поле"; 
                    Layout.fillWidth: true
                    implicitHeight: 40
                    font.pixelSize: 14
                    onTextChanged: createPatientErrorLabel.visible = false
                }

                Text { text: "Фамилия"; font.pixelSize: 12; color: "#666" }
                TextField {
                    id: createPatientSourName
                    palette.placeholderText: "#b91c1c"; placeholderText: "Обязательное поле"; 
                    Layout.fillWidth: true
                    implicitHeight: 40
                    font.pixelSize: 14
                    onTextChanged: createPatientErrorLabel.visible = false
                }

                Text { text: "Полис"; font.pixelSize: 12; color: "#666" }
                TextField {
                    id: createPatientPolicy
                    palette.placeholderText: "#b91c1c"; placeholderText: "Обязательное поле"; 
                    Layout.fillWidth: true
                    implicitHeight: 40
                    font.pixelSize: 14
                    onTextChanged: createPatientErrorLabel.visible = false
                }

                Text { text: "Срок беременности"; font.pixelSize: 12; color: "#666" }
                TextField {
                    id: createPatientPregnancy
                    palette.placeholderText: "#b91c1c"; placeholderText: "Обязательное поле"; 
                    Layout.fillWidth: true
                    implicitHeight: 40
                    font.pixelSize: 14
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
                Button {
                    text: "Найти карту по полису"
                    visible: createPatientErrorLabel.visible && createPatientErrorLabel.text.includes("уже зарегистрирована")
                    onClicked: {
                        createPatientPopup.close()
                        doctorStackView.currentItem.findPolicy(createPatientPolicy.text.trim())
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    spacing: 10

                    Button {
                        text: "Отмена"
                        Layout.fillWidth: true
                        implicitHeight: 40
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
                                noticeTimer.restart()
                                createPatientPopup.close()
                                if (doctorPage.currentTab === "patients") {
                                    doctorStackView.pop(null)
                                    doctorStackView.push(patientsPage)
                                }
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
    StatisticsPopup { id: statisticsPopup }

}