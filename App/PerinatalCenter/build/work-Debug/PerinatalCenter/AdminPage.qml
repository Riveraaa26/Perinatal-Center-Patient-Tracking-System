import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PerinatalCenter 1.0

Item {
    id: adminPage

    property int selectedEmployeeId: -1
    property int selectedDepartmentId: -1
    property string selectedDepartmentName: ""
    property var rolesList: []
    property var collectedChambers: []

    property int chamberToDeleteId: -1
    property bool deleteIsDisease: false

    Component.onCompleted: {
        employeeModel.model = Yadro.getEmployees()
        departmentModel.model = Yadro.getDepartments()
        rolesList = Yadro.getRoles()
    }

    // ==========================================
    // 1. ШАПКА И САЙДБАР
    // ==========================================
    Text {
        id: brandText
        text: "Перинатальный центр"
        font.pixelSize: 20
        font.bold: true
        color: "#333333"
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 40
    }

    Text {
        text: "Администратор"
        font.pixelSize: 24
        font.bold: true
        color: "#333333"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: brandText.verticalCenter
    }

    Button {
        id: logoutButton
        text: "Выйти"
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: brandText.verticalCenter
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
        anchors.top: brandText.bottom
        anchors.topMargin: 30
    }

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
                text: "Сотрудники"
                Layout.fillWidth: true
                implicitHeight: 40
                font.pixelSize: 15
                background: Rectangle {
                    color: parent.down ? "#e0e0e0" : (parent.hovered ? "#eeeeee" : "#ffffff")
                    border.color: "#cccccc"
                    radius: 4
                }
                onClicked: {
                    contentArea.currentPage = "Сотрудники"
                    employeeModel.model = Yadro.getEmployees()
                    adminPage.selectedEmployeeId = -1
                    adminPage.selectedDepartmentId = -1
                }
            }

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
                    contentArea.currentPage = "Отделения"
                    departmentModel.model = Yadro.getDepartments()
                    adminPage.selectedEmployeeId = -1
                    adminPage.selectedDepartmentId = -1
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    // ==========================================
    // 2. РАБОЧАЯ ОБЛАСТЬ
    // ==========================================
    Item {
        id: contentArea
        anchors.top: headerLine.bottom
        anchors.bottom: parent.bottom
        anchors.left: sidebar.right
        anchors.right: parent.right

        property string currentPage: "Сотрудники"

        Text {
            id: pageTitle
            text: contentArea.currentPage
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
            anchors.bottom: buttonRow.top
            anchors.bottomMargin: 15

            color: "#ffffff"
            border.color: "#e0e0e0"
            border.width: 1
            radius: 8

            ListView {
                id: employeeModel
                visible: contentArea.currentPage === "Сотрудники"
                anchors.fill: parent
                anchors.margins: 10
                clip: true
                focus: true
                highlightFollowsCurrentItem: false
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: 10
                }

                header: Rectangle {
                    width: employeeModel.width - 10
                    height: 35
                    color: "#f0f0f0"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10

                        Text { text: "ФИО"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                        Text { text: "Логин"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                        Text { text: "Пароль"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                        Text { text: "Роль"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                    }
                }

                delegate: Rectangle {
                    width: employeeModel.width - 10
                    height: 40
                    color: employeeModel.currentIndex === index ? "#cce5ff" : (index % 2 === 0 ? "#ffffff" : "#f9f9f9")
                    border.color: "#eeeeee"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10

                        Text { text: modelData.full_name !== undefined ? modelData.full_name : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                        Text { text: modelData.login !== undefined ? modelData.login : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                        Text { text: modelData.password !== undefined ? modelData.password : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                        Text { text: modelData.role !== undefined ? modelData.role : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton

                        onClicked: {
                            employeeModel.currentIndex = index
                            adminPage.selectedEmployeeId = parseInt(modelData.id)
                        }

                        onDoubleClicked: {
                            employeeModel.currentIndex = index
                            adminPage.selectedEmployeeId = parseInt(modelData.id)

                            editName.text = modelData.name !== undefined ? modelData.name : ""
                            editSourName.text = modelData.sour_name !== undefined ? modelData.sour_name : ""
                            editLogin.text = modelData.login !== undefined ? modelData.login : ""
                            editPassword.text = modelData.password !== undefined ? modelData.password : ""

                            for (let i = 0; i < adminPage.rolesList.length; i++) {
                                if (adminPage.rolesList[i].id === modelData.role_id) {
                                    editRoleCombo.currentIndex = i
                                    break
                                }
                            }

                            editPopup.open()
                        }
                    }
                }
            }

            ListView {
                id: departmentModel
                visible: contentArea.currentPage === "Отделения"
                anchors.fill: parent
                anchors.margins: 10
                clip: true
                focus: true
                highlightFollowsCurrentItem: false
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: 10
                }

                header: Rectangle {
                    width: departmentModel.width - 10
                    height: 35
                    color: "#f0f0f0"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10

                        Text { text: "Название отделения"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                        Text { text: "Всего палат"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                        Text { text: "Из них инкубаторов"; font.bold: true; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                    }
                }

                delegate: Rectangle {
                    width: departmentModel.width - 10
                    height: 40
                    color: departmentModel.currentIndex === index ? "#cce5ff" : (index % 2 === 0 ? "#ffffff" : "#f9f9f9")
                    border.color: "#eeeeee"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10

                        Text { text: modelData.name !== undefined ? modelData.name : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                        Text { text: modelData.capacity !== undefined ? modelData.capacity : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                        Text { text: modelData.capacity_disease !== undefined ? modelData.capacity_disease : "—"; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; font.pixelSize: 14 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton

                        onClicked: {
                            departmentModel.currentIndex = index
                            adminPage.selectedDepartmentId = parseInt(modelData.id)
                        }

                        onDoubleClicked: {
                            departmentModel.currentIndex = index
                            adminPage.selectedDepartmentId = parseInt(modelData.id)
                            adminPage.selectedDepartmentName = modelData.name
                            departmentActionPopup.open()
                        }
                    }
                }
            }

            Text {
                text: "Данные отсутствуют"
                anchors.centerIn: parent
                color: "#999999"
                visible: (contentArea.currentPage === "Сотрудники" && employeeModel.count === 0) ||
                         (contentArea.currentPage === "Отделения" && departmentModel.count === 0)
            }
        }

        RowLayout {
            id: buttonRow
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            spacing: 15

            Button {
                text: "Создать пользователя"
                visible: contentArea.currentPage === "Сотрудники"
                implicitHeight: 40
                implicitWidth: 180
                font.pixelSize: 15

                onClicked: {
                    createName.text = ""
                    createSourName.text = ""
                    createLogin.text = ""
                    createPassword.text = ""
                    createRoleCombo.currentIndex = 0
                    createPopup.open()
                }
            }

            Button {
                text: "Удалить пользователя"
                visible: contentArea.currentPage === "Сотрудники"
                implicitHeight: 40
                implicitWidth: 180
                font.pixelSize: 15
                enabled: adminPage.selectedEmployeeId !== -1

                onClicked: {
                    deletePopup.open()
                }
            }

            Button {
                text: "Создать отделение"
                visible: contentArea.currentPage === "Отделения"
                implicitHeight: 40
                implicitWidth: 180
                font.pixelSize: 15

                onClicked: {
                    createDeptName.text = ""
                    createDeptCapacity.text = ""
                    createDeptCapacityDisease.text = ""
                    createDeptErrorLabel.visible = false
                    adminPage.collectedChambers = []
                    createDeptPopup.open()
                }
            }
        }
    }

    // ==========================================
    // 3. МЕНЮ ДЕЙСТВИЙ С ОТДЕЛЕНИЕМ
    // ==========================================
    Popup {
        id: departmentActionPopup
        width: 350
        height: 220
        anchors.centerIn: parent
        modal: true
        focus: true
        background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 8 }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 15

            Text {
                text: "Выберите действие"
                font.pixelSize: 18
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 10
            }

            Button {
                text: "Изменить название отделения"
                Layout.fillWidth: true
                implicitHeight: 40
                font.pixelSize: 15

                onClicked: {
                    departmentActionPopup.close()
                    editDeptNameInput.text = adminPage.selectedDepartmentName
                    editNamePopup.open()
                }
            }

            Button {
                text: "Изменить кол-во палат"
                Layout.fillWidth: true
                implicitHeight: 40
                font.pixelSize: 15

                onClicked: {
                    departmentActionPopup.close()
                    chamberActionsPopup.open()
                }
            }

            Item { Layout.fillHeight: true }

            Button {
                text: "Отмена"
                Layout.fillWidth: true
                implicitHeight: 40
                font.pixelSize: 15

                onClicked: {
                    departmentActionPopup.close()
                }
            }
        }
    }

    // ==========================================
    // 4. ПОПАПЫ ДЛЯ СОТРУДНИКОВ
    // ==========================================
    Popup {
        id: createPopup
        width: 400
        height: 520
        anchors.centerIn: parent
        modal: true
        focus: true
        background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 8 }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 15

            Text { text: "Новый сотрудник"; font.pixelSize: 20; font.bold: true; Layout.alignment: Qt.AlignHCenter; Layout.bottomMargin: 10 }

            Text { text: "Имя"; font.pixelSize: 12; color: "#666" }
            TextField { id: createName; Layout.fillWidth: true; implicitHeight: 40; font.pixelSize: 14; onTextChanged: createErrorLabel.visible = false }

            Text { text: "Фамилия"; font.pixelSize: 12; color: "#666" }
            TextField { id: createSourName; Layout.fillWidth: true; implicitHeight: 40; font.pixelSize: 14; onTextChanged: createErrorLabel.visible = false }

            Text { text: "Логин"; font.pixelSize: 12; color: "#666" }
            TextField { id: createLogin; Layout.fillWidth: true; implicitHeight: 40; font.pixelSize: 14; onTextChanged: createErrorLabel.visible = false }

            Text { text: "Пароль"; font.pixelSize: 12; color: "#666" }
            TextField { id: createPassword; Layout.fillWidth: true; implicitHeight: 40; font.pixelSize: 14; onTextChanged: createErrorLabel.visible = false }

            Text { text: "Роль"; font.pixelSize: 12; color: "#666" }
            ComboBox {
                id: createRoleCombo
                Layout.fillWidth: true
                implicitHeight: 40
                model: adminPage.rolesList
                textRole: "name"
                delegate: ItemDelegate {
                    width: createRoleCombo.width
                    contentItem: Text {
                        text: modelData.name
                        font.pixelSize: 14
                        verticalAlignment: Text.AlignVCenter
                    }
                    highlighted: createRoleCombo.highlightedIndex === index
                }
            }

            Text { id: createErrorLabel; color: "red"; font.pixelSize: 13; wrapMode: Text.WordWrap; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter; visible: false }
            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    text: "Отмена"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    onClicked: {
                        createPopup.close()
                    }
                }

                Button {
                    text: "Создать"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    enabled: createName.text.trim() !== "" && createSourName.text.trim() !== "" && createLogin.text.trim() !== "" && createPassword.text.trim() !== "" && createRoleCombo.currentIndex >= 0

                    onClicked: {
                        createErrorLabel.visible = false
                        let selectedRoleId = 1

                        if (createRoleCombo.currentIndex >= 0 && adminPage.rolesList.length > 0) {
                            selectedRoleId = adminPage.rolesList[createRoleCombo.currentIndex].id
                        }

                        const err = Yadro.createEmployee(createName.text, createSourName.text, createLogin.text, createPassword.text, selectedRoleId)

                        if (err.length === 0) {
                            createPopup.close()
                            employeeModel.model = Yadro.getEmployees()
                        } else {
                            createErrorLabel.text = err
                            createErrorLabel.visible = true
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: editPopup
        width: 400
        height: 520
        anchors.centerIn: parent
        modal: true
        focus: true
        background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 8 }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 15

            Text { text: "Редактирование профиля"; font.pixelSize: 20; font.bold: true; Layout.alignment: Qt.AlignHCenter; Layout.bottomMargin: 10 }

            Text { text: "Имя"; font.pixelSize: 12; color: "#666" }
            TextField { id: editName; Layout.fillWidth: true; implicitHeight: 40; font.pixelSize: 14; onTextChanged: editErrorLabel.visible = false }

            Text { text: "Фамилия"; font.pixelSize: 12; color: "#666" }
            TextField { id: editSourName; Layout.fillWidth: true; implicitHeight: 40; font.pixelSize: 14; onTextChanged: editErrorLabel.visible = false }

            Text { text: "Логин"; font.pixelSize: 12; color: "#666" }
            TextField { id: editLogin; Layout.fillWidth: true; implicitHeight: 40; font.pixelSize: 14; onTextChanged: editErrorLabel.visible = false }

            Text { text: "Пароль"; font.pixelSize: 12; color: "#666" }
            TextField { id: editPassword; Layout.fillWidth: true; implicitHeight: 40; font.pixelSize: 14; onTextChanged: editErrorLabel.visible = false }

            Text { text: "Роль"; font.pixelSize: 12; color: "#666" }
            ComboBox {
                id: editRoleCombo
                Layout.fillWidth: true
                implicitHeight: 40
                model: adminPage.rolesList
                textRole: "name"
                delegate: ItemDelegate {
                    width: editRoleCombo.width
                    contentItem: Text {
                        text: modelData.name
                        font.pixelSize: 14
                        verticalAlignment: Text.AlignVCenter
                    }
                    highlighted: editRoleCombo.highlightedIndex === index
                }
            }

            Text { id: editErrorLabel; color: "red"; font.pixelSize: 13; wrapMode: Text.WordWrap; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter; visible: false }
            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    text: "Отмена"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    onClicked: {
                        editPopup.close()
                    }
                }

                Button {
                    text: "Сохранить"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    enabled: editName.text.trim() !== "" && editSourName.text.trim() !== "" && editLogin.text.trim() !== "" && editPassword.text.trim() !== ""

                    onClicked: {
                        editErrorLabel.visible = false
                        let selectedRoleId = 1

                        if (editRoleCombo.currentIndex >= 0 && adminPage.rolesList.length > 0) {
                            selectedRoleId = adminPage.rolesList[editRoleCombo.currentIndex].id
                        }

                        const err = Yadro.updateEmployee(adminPage.selectedEmployeeId, editName.text, editSourName.text, editLogin.text, editPassword.text, selectedRoleId)

                        if (err.length === 0) {
                            editPopup.close()
                            employeeModel.model = Yadro.getEmployees()
                            adminPage.selectedEmployeeId = -1
                        } else {
                            editErrorLabel.text = err
                            editErrorLabel.visible = true
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: deletePopup
        width: 350
        height: 200
        anchors.centerIn: parent
        modal: true
        focus: true
        background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 8 }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text { text: "Вы уверены, что хотите удалить\nэтого сотрудника?"; font.pixelSize: 16; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true }
            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    text: "Отмена"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    onClicked: {
                        deletePopup.close()
                    }
                }

                Button {
                    text: "Удалить"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    background: Rectangle {
                        color: "#d9534f"
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        const err = Yadro.deleteEmployee(adminPage.selectedEmployeeId)

                        if (err.length === 0) {
                            deletePopup.close()
                            employeeModel.model = Yadro.getEmployees()
                            adminPage.selectedEmployeeId = -1
                        } else {
                            console.error(err)
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // 5. ПОПАПЫ ДЛЯ ОТДЕЛЕНИЙ
    // ==========================================

    Popup {
        id: createDeptPopup
        width: 400
        height: 380
        anchors.centerIn: parent
        modal: true
        focus: true
        background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 8 }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 15

            Text { text: "Новое отделение"; font.pixelSize: 20; font.bold: true; Layout.alignment: Qt.AlignHCenter }

            Text { text: "Название"; font.pixelSize: 12; color: "#666" }
            TextField { id: createDeptName; Layout.fillWidth: true; implicitHeight: 40 }

            Text { text: "Всего палат"; font.pixelSize: 12; color: "#666" }
            TextField { id: createDeptCapacity; Layout.fillWidth: true; implicitHeight: 40; validator: IntValidator { bottom: 0 } }

            Text { text: "Из них инкубаторов"; font.pixelSize: 12; color: "#666" }
            TextField { id: createDeptCapacityDisease; Layout.fillWidth: true; implicitHeight: 40; validator: IntValidator { bottom: 0 } }

            Text {
                id: createDeptErrorLabel
                color: "red"
                font.pixelSize: 13
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                visible: false
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    text: "Отмена"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    onClicked: {
                        createDeptPopup.close()
                    }
                }

                Button {
                    text: "Далее"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    enabled: createDeptName.text.trim() !== "" && createDeptCapacity.text.trim() !== "" && createDeptCapacityDisease.text.trim() !== ""

                    onClicked: {
                        createDeptErrorLabel.visible = false
                        let total = parseInt(createDeptCapacity.text)
                        let disease = parseInt(createDeptCapacityDisease.text)

                        if (disease > total) {
                            createDeptErrorLabel.text = "Инкубаторов не может быть больше общего количества!"
                            createDeptErrorLabel.visible = true
                            return
                        }

                        adminPage.collectedChambers = []
                        chambersWizard.totalChambers = total
                        chambersWizard.totalDisease = disease
                        chambersWizard.currentIndex = 0
                        chambersWizard.diseaseCreated = 0
                        chambersWizard.deptName = createDeptName.text

                        createDeptPopup.close()

                        if (total > 0) {
                            chambersWizard.open()
                        } else {
                            let err = Yadro.createDepartment(createDeptName.text, 0, 0, [])

                            if (err.length === 0) {
                                departmentModel.model = Yadro.getDepartments()
                            } else {
                                console.error(err)
                            }
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: chambersWizard
        width: 400
        height: 380
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose
        background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 8 }

        property string deptName: ""
        property int totalChambers: 0
        property int totalDisease: 0
        property int currentIndex: 0
        property int diseaseCreated: 0

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 15

            Text {
                text: "Палата " + (chambersWizard.currentIndex + 1) + " из " + chambersWizard.totalChambers
                font.pixelSize: 20
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 10
            }

            Text { text: "Номер палаты"; font.pixelSize: 12; color: "#666" }
            TextField {
                id: wizardChamberNumber
                Layout.fillWidth: true
                implicitHeight: 40
                font.pixelSize: 14
                text: (chambersWizard.currentIndex + 1).toString()
                readOnly: true
            }

            Text { text: "Вместимость (мест)"; font.pixelSize: 12; color: "#666" }
            TextField {
                id: wizardChamberCapacity
                Layout.fillWidth: true
                implicitHeight: 40
                font.pixelSize: 14
                validator: IntValidator { bottom: 1 }
                onVisibleChanged: text = ""
            }

            Text {
                text: "Инкубатор (для больных): " + (((chambersWizard.totalChambers - chambersWizard.currentIndex) <= (chambersWizard.totalDisease - chambersWizard.diseaseCreated)) ? "Да" : "Нет")
                font.pixelSize: 14
                color: (((chambersWizard.totalChambers - chambersWizard.currentIndex) <= (chambersWizard.totalDisease - chambersWizard.diseaseCreated)) ? "#d9534f" : "#666")
                Layout.topMargin: 5
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    text: "Отмена (прервать)"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    onClicked: {
                        chambersWizard.close()
                        adminPage.collectedChambers = []
                    }
                }

                Button {
                    text: (chambersWizard.currentIndex + 1 === chambersWizard.totalChambers) ? "Завершить" : "Следующая палата"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    enabled: wizardChamberCapacity.text !== ""

                    onClicked: {
                        let isDisease = (chambersWizard.totalChambers - chambersWizard.currentIndex) <= (chambersWizard.totalDisease - chambersWizard.diseaseCreated)

                        let newChamber = {
                            "number": parseInt(wizardChamberNumber.text),
                            "capacity": parseInt(wizardChamberCapacity.text),
                            "disease": isDisease
                        }

                        adminPage.collectedChambers.push(newChamber)

                        chambersWizard.currentIndex++

                        if (isDisease) {
                            chambersWizard.diseaseCreated++
                        }

                        if (chambersWizard.currentIndex === chambersWizard.totalChambers) {
                            let err = Yadro.createDepartment(
                                chambersWizard.deptName,
                                chambersWizard.totalChambers,
                                chambersWizard.totalDisease,
                                adminPage.collectedChambers
                            )

                            if (err.length === 0) {
                                chambersWizard.close()
                                adminPage.collectedChambers = []
                                departmentModel.model = Yadro.getDepartments()
                            } else {
                                console.error(err)
                            }
                        } else {
                            wizardChamberCapacity.text = ""
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: editNamePopup
        width: 350
        height: 200
        anchors.centerIn: parent
        modal: true
        focus: true
        background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 8 }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text { text: "Новое название"; font.pixelSize: 16; font.bold: true }
            TextField { id: editDeptNameInput; Layout.fillWidth: true; implicitHeight: 40 }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    text: "Отмена"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    onClicked: {
                        editNamePopup.close()
                    }
                }

                Button {
                    text: "Сохранить"
                    Layout.fillWidth: true
                    implicitHeight: 40

                    onClicked: {
                        let err = Yadro.updateDepartmentName(adminPage.selectedDepartmentId, editDeptNameInput.text)

                        if (err.length === 0) {
                            editNamePopup.close()
                            departmentModel.model = Yadro.getDepartments()
                        } else {
                            console.error(err)
                        }
                    }
                }
            }
        }
    }

    // ✅ МЕНЮ ДОБАВИТЬ/УБРАТЬ
    Popup {
        id: chamberActionsPopup
        width: 350
        height: 250
        anchors.centerIn: parent
        modal: true
        focus: true
        background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 8 }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text { text: "Действие с палатами"; font.pixelSize: 16; font.bold: true; Layout.alignment: Qt.AlignHCenter }

            Button {
                text: "Добавить палату"
                Layout.fillWidth: true
                implicitHeight: 40

                onClicked: {
                    chamberActionsPopup.close()
                    addChamberNumber.text = Yadro.getNextChamberNumber(adminPage.selectedDepartmentId).toString()
                    addChamberCapacity.text = ""
                    addChamberDisease.checked = false
                    addChamberPopup.open()
                }
            }

            Button {
                text: "Убрать палату"
                Layout.fillWidth: true
                implicitHeight: 40

                onClicked: {
                    chamberActionsPopup.close()
                    removeChamberTypePopup.open()
                }
            }

            Button {
                text: "Отмена"
                Layout.fillWidth: true
                implicitHeight: 40
                onClicked: {
                    chamberActionsPopup.close()
                }
            }
        }
    }

    // ✅ НОВОЕ МЕНЮ: выбор типа удаляемой палаты
    Popup {
        id: removeChamberTypePopup
        width: 350
        height: 250
        anchors.centerIn: parent
        modal: true
        focus: true
        background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 8 }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text { text: "Какую палату убрать?"; font.pixelSize: 16; font.bold: true; Layout.alignment: Qt.AlignHCenter }

            Button {
                text: "Обычную палату"
                Layout.fillWidth: true
                implicitHeight: 40

                onClicked: {
                    removeChamberTypePopup.close()

                    let lastChamber = Yadro.getLastChamberByType(adminPage.selectedDepartmentId, false)

                    if (lastChamber.id === undefined) {
                        deleteChamberError.text = "В отделении нет обычных палат для удаления."
                        deleteChamberError.visible = true
                        removeChamberPopup.open()
                        return
                    }

                    adminPage.chamberToDeleteId = lastChamber.id
                    adminPage.deleteIsDisease = false

                    if (lastChamber.load > 0) {
                        deleteChamberError.text = "Невозможно удалить палату №" + lastChamber.number + ", так как в ней есть пациенты!"
                        deleteChamberError.visible = true
                    } else {
                        deleteChamberError.visible = false
                    }

                    removeChamberPopup.open()
                }
            }

            Button {
                text: "Инкубатор"
                Layout.fillWidth: true
                implicitHeight: 40

                onClicked: {
                    removeChamberTypePopup.close()

                    let lastChamber = Yadro.getLastChamberByType(adminPage.selectedDepartmentId, true)

                    if (lastChamber.id === undefined) {
                        deleteChamberError.text = "В отделении нет инкубаторов для удаления."
                        deleteChamberError.visible = true
                        removeChamberPopup.open()
                        return
                    }

                    adminPage.chamberToDeleteId = lastChamber.id
                    adminPage.deleteIsDisease = true

                    if (lastChamber.load > 0) {
                        deleteChamberError.text = "Невозможно удалить палату №" + lastChamber.number + ", так как в ней есть пациенты!"
                        deleteChamberError.visible = true
                    } else {
                        deleteChamberError.visible = false
                    }

                    removeChamberPopup.open()
                }
            }

            Button {
                text: "Отмена"
                Layout.fillWidth: true
                implicitHeight: 40
                onClicked: {
                    removeChamberTypePopup.close()
                }
            }
        }
    }

    Popup {
        id: addChamberPopup
        width: 350
        height: 350
        anchors.centerIn: parent
        modal: true
        focus: true
        background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 8 }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text { text: "Новая палата"; font.pixelSize: 16; font.bold: true }

            Text { text: "Номер палаты (автоматически)"; font.pixelSize: 12; color: "#666" }
            TextField { id: addChamberNumber; Layout.fillWidth: true; implicitHeight: 40; readOnly: true }

            Text { text: "Кол-во мест"; font.pixelSize: 12; color: "#666" }
            TextField { id: addChamberCapacity; Layout.fillWidth: true; implicitHeight: 40; validator: IntValidator { bottom: 1 } }

            CheckBox { id: addChamberDisease; text: "Инкубатор (для больных)"; font.pixelSize: 14 }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    text: "Отмена"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    onClicked: {
                        addChamberPopup.close()
                    }
                }

                Button {
                    text: "Создать"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    enabled: addChamberCapacity.text !== ""

                    onClicked: {
                        let err = Yadro.addChamber(adminPage.selectedDepartmentId, parseInt(addChamberNumber.text), parseInt(addChamberCapacity.text), addChamberDisease.checked)

                        if (err.length === 0) {
                            addChamberPopup.close()
                            departmentModel.model = Yadro.getDepartments()
                        } else {
                            console.error(err)
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: removeChamberPopup
        width: 350
        height: 250
        anchors.centerIn: parent
        modal: true
        focus: true
        background: Rectangle { color: "#ffffff"; border.color: "#cccccc"; radius: 8 }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text { text: "Удаление палаты"; font.pixelSize: 16; font.bold: true }

            Text { id: deleteChamberError; color: "red"; font.pixelSize: 13; wrapMode: Text.WordWrap; Layout.fillWidth: true; visible: false }

            Text { text: "Вы уверены, что хотите удалить эту палату?"; font.pixelSize: 14; wrapMode: Text.WordWrap; Layout.fillWidth: true }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    text: "Отмена"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    onClicked: {
                        removeChamberPopup.close()
                    }
                }

                Button {
                    text: "Удалить"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    background: Rectangle {
                        color: "#d9534f"
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        if (adminPage.chamberToDeleteId !== -1) {
                            let err = Yadro.deleteChamber(adminPage.chamberToDeleteId)

                            if (err.length === 0) {
                                removeChamberPopup.close()
                                departmentModel.model = Yadro.getDepartments()
                            } else {
                                deleteChamberError.text = err
                                deleteChamberError.visible = true
                            }
                        }
                    }
                }
            }
        }
    }
}