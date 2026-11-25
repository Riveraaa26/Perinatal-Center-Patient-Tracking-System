import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PerinatalCenter 1.0

Item {
    id: loginPage

    // Цветовая палитра
    property color accentColor: "#ffb3c6"
    property color accentHover: "#ff8fab"

    // 1. ШАПКА
    Row {
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 30
        spacing: 10

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                id: headerText
                text: "Перинатальный центр"
                font.pixelSize: 20
                font.bold: true
                color: "#333333"
            }
            Text {
                text: "Система управления"
                font.pixelSize: 13
                font.italic: true
                color: "#888888"
            }
        }
    }

    Rectangle {
        id: headerLine
        width: parent.width
        height: 2
        color: "#d3d3d3"
        anchors.top: parent.top
        anchors.topMargin: 90
    }

    // 2. ФОРМА ВХОДА
    Item {
        id: contentArea
        anchors.top: headerLine.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        Rectangle {
            id: loginBox
            width: 380
            height: 420
            color: "#ffffff"
            border.color: accentColor
            border.width: 2
            radius: 16

            anchors.centerIn: parent

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 30
                spacing: 15

                Text {
                    text: "Вход в систему"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#333333"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 10
                }

                Text { text: "Логин"; font.pixelSize: 12; color: "#666"; Layout.topMargin: 5 }
                TextField {
                    id: loginField
                    placeholderText: "Введите логин..."
                    Layout.fillWidth: true
                    font.pixelSize: 15
                    implicitHeight: 45
                    leftPadding: 15
                    background: Rectangle {
                        color: "#fdfdfd"
                        border.color: loginField.activeFocus ? accentColor : "#cccccc"
                        border.width: loginField.activeFocus ? 2 : 1
                        radius: 10
                    }
                }

                Text { text: "Пароль"; font.pixelSize: 12; color: "#666"; Layout.topMargin: 5 }
                TextField {
                    id: passwordField
                    placeholderText: "Введите пароль..."
                    echoMode: TextInput.Password
                    Layout.fillWidth: true
                    font.pixelSize: 15
                    implicitHeight: 45
                    leftPadding: 15
                    background: Rectangle {
                        color: "#fdfdfd"
                        border.color: passwordField.activeFocus ? accentColor : "#cccccc"
                        border.width: passwordField.activeFocus ? 2 : 1
                        radius: 10
                    }
                    onAccepted: loginButton.clicked()
                }

                Text {
                    id: errorLabel
                    color: "#d32f2f"
                    font.pixelSize: 13
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    visible: false
                    Layout.topMargin: 5
                }

                Item { Layout.fillHeight: true }

                Button {
                    id: loginButton
                    text: "Войти 🎀"
                    Layout.fillWidth: true
                    implicitHeight: 48
                    font.pixelSize: 16
                    font.bold: true

                    background: Rectangle {
                        color: parent.down ? accentColor : (parent.hovered ? "#fff0f5" : "#ffffff")
                        border.color: accentColor
                        border.width: 2
                        radius: 12
                    }

                    onClicked: {
                        errorLabel.visible = false
                        const result = Yadro.loginUser(loginField.text, passwordField.text)

                        if (!result.includes("|")) {
                            errorLabel.text = result
                            errorLabel.visible = true
                            return
                        }

                        const parts = result.split("|")
                        const fullName = parts[0]
                        const roleName = parts[1]
                        const empId = parseInt(parts[2])

                        if (roleName === "Администратор") {
                            stackView.push("AdminPage.qml")
                        } else if (roleName === "Врач акушер-гинеколог" || roleName === "Врач") {
                            stackView.push("DoctorPage.qml", {
                                "currentUserLogin": loginField.text,
                                "currentUserFullName": fullName,
                                "currentEmployeeId": empId
                            })
                        } else if (roleName === "Заведующая отделением" || roleName === "Заведующий отделением") {
                            stackView.push("HeadDoctorPage.qml", {
                                "currentUserLogin": loginField.text,
                                "currentUserFullName": fullName,
                                "currentEmployeeId": empId
                            })
                        } else {
                            stackView.push("NursePage.qml", {
                                "currentUserLogin": loginField.text,
                                "currentUserFullName": fullName,
                                "currentEmployeeId": empId
                            })
                        }
                    }
                }
            }
        }
    }
}