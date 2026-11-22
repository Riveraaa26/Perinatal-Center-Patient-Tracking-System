import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PerinatalCenter 1.0

Item {
    id: nursePage

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

    property string currentTab: "departments"

    // 1. ШАПКА
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
        text: nursePage.currentUserFullName
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
            Yadro.logoutUser()
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

    // 2. САЙДБАР
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
                    nursePage.currentTab = "departments"
                    nurseStackView.pop(null)
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
                    nursePage.currentTab = "patients"
                    nurseStackView.pop(null)
                    nurseStackView.push(patientsPage)
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    // 3. РАБОЧАЯ ЗОНА
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

            // СТРАНИЦА 1: ОТДЕЛЕНИЯ
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
                                onClicked: {
                                    deptModel.currentIndex = index
                                }
                                onDoubleClicked: {
                                    nurseStackView.push(chambersPage, {
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

    // 4. СТРАНИЦА ПАЛАТ
    Component {
        id: chambersPage

        Item {
            id: chambersItem
            property int deptId: -1
            property string deptName: ""

            Component.onCompleted: {
                chamberModel.model = Yadro.getChambersByDepartment(chambersItem.deptId)
            }
            Timer {
                interval: 8000; repeat: true; running: chambersItem.visible
                onTriggered: chamberModel.model = Yadro.getChambersByDepartment(chambersItem.deptId)
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
                        nurseStackView.pop()
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

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                const list = Yadro.getPatientsByChamber(chambersItem.deptId, modelData.number)
                                roomInfo.title = "Палата " + modelData.number
                                roomInfoText.text = Yadro.readError || (list.length ? list.map(p => p.full_name).join("\n") : "Пациенток нет")
                                roomInfo.open()
                            }
                        }
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10
                            Text { text: modelData.number; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text {
                                text: modelData.kind === "operating" ? "Операционная" : modelData.disease ? "Изолятор" : "Обычная"
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

    // 5. СТРАНИЦА ПАЦИЕНТОВ
    Component {
        id: patientsPage

        Item {
            id: patientsItem

            property var allPatients: []
            property var filteredPatients: []

            Component.onCompleted: {
                loadPatients()
            }

            function loadPatients() {
                allPatients = Yadro.getPatients()
                patientsItem.filteredPatients = allPatients
                searchField.text = ""
            }
            function refreshPatients() {
                allPatients = Yadro.getPatients()
                filterPatients()
            }
            Timer {
                interval: 8000; repeat: true; running: patientsItem.visible && !registerPopup.visible
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
                    if ((pat.full_name && pat.full_name.toLowerCase().includes(query)) || String(pat.policy).includes(query)) {
                        result.push(pat)
                    }
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
                        onTextChanged: patientsItem.filterPatients()
                    }

                    Button {
                        width: 24
                        height: 24
                        anchors.right: parent.right
                        anchors.rightMargin: 5
                        anchors.verticalCenter: parent.verticalCenter
                        visible: searchField.text !== ""

                        background: Rectangle {
                            color: "transparent"
                            radius: 12
                        }
                        contentItem: Text {
                            text: "✕"
                            font.pixelSize: 14
                            color: "#666666"
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
                    text: "Добавить пациентку"
                    implicitWidth: 165
                    implicitHeight: 35
                    onClicked: registerPopup.openForm()
                }
                Button {
                    text: "Обновить"
                    implicitWidth: 100
                    implicitHeight: 35
                    font.pixelSize: 14
                    onClicked: {
                        patientsItem.loadPatients()
                    }
                }

                Button {
                    text: "Назад"
                    implicitWidth: 100
                    implicitHeight: 35
                    font.pixelSize: 14
                    onClicked: {
                        nursePage.currentTab = "departments"
                        nurseStackView.pop(null)
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
                            Text {
                                text: modelData.disease ? "Да" : "—"
                                Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14
                            }
                            Text { text: modelData.discharged ? "Выписана" : (modelData.department !== "" ? modelData.department : "—"); Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                            Text { text: modelData.chamber !== "" ? modelData.chamber : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
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
        }
    }
    // UC-08: регистрация пациентки доступна медсестре.
    Popup {
        id: registerPopup
        width: 450
        height: 480
        anchors.centerIn: parent
        modal: true
        focus: true
        background: Rectangle { color: "#ffffff"; radius: 8; border.color: "#cccccc" }
        function openForm() {
            regName.text = ""; regSurname.text = ""; regPolicy.text = "";
            regWeeks.text = ""; regDisease.checked = false; regError.text = "";
            open()
        }
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 24; spacing: 9
            Text { text: "Регистрация пациентки"; font.pixelSize: 20; font.bold: true; Layout.alignment: Qt.AlignHCenter }
            Text { text: "Имя *" }
            TextField { id: regName; palette.placeholderText: "#b91c1c";  Layout.fillWidth: true; placeholderText: "Имя" }
            Text { text: "Фамилия *" }
            TextField { id: regSurname; palette.placeholderText: "#b91c1c";  Layout.fillWidth: true; placeholderText: "Фамилия" }
            Text { text: "Полис ОМС — 16 цифр *" }
            TextField { id: regPolicy; palette.placeholderText: "#b91c1c";  Layout.fillWidth: true; placeholderText: "1234567890123456"; maximumLength: 16 }
            Text { text: "Срок беременности (недели) *" }
            TextField { id: regWeeks; palette.placeholderText: "#b91c1c";  Layout.fillWidth: true; placeholderText: "Например, 35" }
            CheckBox { id: regDisease; text: "Требуется изолятор" }
            Text { id: regError; color: "#b91c1c"; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                Button {
                    text: "Найти карту по полису"
                    visible: regError.visible && regError.text.includes("уже зарегистрирована")
                    onClicked: {
                        registerPopup.close()
                        nurseStackView.currentItem.findPolicy(regPolicy.text.trim())
                    }
                }
            Item { Layout.fillHeight: true }
            RowLayout {
                Layout.fillWidth: true
                Button { text: "Отмена"; Layout.fillWidth: true; onClicked: registerPopup.close() }
                Button {
                    id: registerSave
                    text: "Зарегистрировать"
                    Layout.fillWidth: true
                    enabled: regName.text.trim() && regSurname.text.trim() && regPolicy.text.trim() && regWeeks.text.trim()
                    onClicked: {
                        const err = Yadro.createPatient(regName.text,regSurname.text,regPolicy.text,regWeeks.text,regDisease.checked)
                        if (err.length > 0) regError.text = err
                        else {
                            noticeTimer.restart()
                            registerPopup.close()
                            nurseStackView.pop(null)
                            nurseStackView.push(patientsPage)
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: roomInfo
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Ok
        contentItem: Label { id: roomInfoText; wrapMode: Text.Wrap }
    }

}