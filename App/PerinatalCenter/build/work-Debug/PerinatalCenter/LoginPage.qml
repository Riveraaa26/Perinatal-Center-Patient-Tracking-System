import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PerinatalCenter 1.0

Item {
    id: loginPage

    Text {
        id: headerText
        text: "Перинатальный центр"
        font.pixelSize: 28
        font.bold: true
        color: "#333333"
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Rectangle {
        id: headerLine
        width: parent.width
        height: 2
        color: "#d3d3d3"
        anchors.top: headerText.bottom
        anchors.topMargin: 30
    }

    Item {
        id: contentArea
        anchors.top: headerLine.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        Rectangle {
            id: loginBox
            width: 350
            height: 300
            color: "#f9f9f9"
            border.color: "#e0e0e0"
            border.width: 1
            radius: 8

            anchors.centerIn: parent

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 30
                spacing: 15

                Text {
                    text: "Вход в систему"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333333"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 10
                }

                TextField {
                    id: loginField
                    placeholderText: "Логин"
                    Layout.fillWidth: true
                    font.pixelSize: 16
                    implicitHeight: 40
                }

                TextField {
                    id: passwordField
                    placeholderText: "Пароль"
                    echoMode: TextInput.Password
                    Layout.fillWidth: true
                    font.pixelSize: 16
                    implicitHeight: 40
                }

                Text {
                    id: errorLabel
                    color: "red"
                    font.pixelSize: 14
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    visible: false
                }

                Button {
                    text: "Войти"
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    implicitHeight: 40
                    font.pixelSize: 16

                    onClicked: {
                        errorLabel.visible = false
                        const result = Yadro.loginUser(loginField.text, passwordField.text)

                        // Проверяем на ошибки (если нет разделителя |, значит это ошибка)
                        if (!result.includes("|")) {
                            errorLabel.text = result
                            errorLabel.visible = true
                            return
                        }

                        // Разделяем ФИО и Роль
                        const parts = result.split("|")
                        const fullName = parts[0]
                        const roleName = parts[1]

                        // Распределяем по ролям
                        if (roleName === "Администратор") {
                            stackView.push("AdminPage.qml")
                        } else if (roleName === "Врач акушер-гинеколог" || roleName === "Врач") {
                            stackView.push("DoctorPage.qml", {
                                "currentUserLogin": loginField.text,
                                "currentUserFullName": fullName
                            })
                        } else {
                            // По умолчанию (или если роль "Медсестра") кидаем к медсестре
                            stackView.push("NursePage.qml", {
                                "currentUserLogin": loginField.text,
                                "currentUserFullName": fullName
                            })
                        }
                    }
                }
            }
        }
    }
}