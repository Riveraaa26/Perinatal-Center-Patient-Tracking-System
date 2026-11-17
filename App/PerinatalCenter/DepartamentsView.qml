import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PerinatalCenter 1.0

Item {
    id: departmentsView

    Component.onCompleted: {
        departmentModel.model = Yadro.getDepartments()
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
            id: departmentModel
            anchors.fill: parent
            anchors.margins: 10
            clip: true
            highlightFollowsCurrentItem: false
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded; width: 10 }

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
                    }

                    onDoubleClicked: {
                        // ✅ Переход на страницу палат с анимацией
                        stackView.push("ChambersView.qml", {
                            "deptId": parseInt(modelData.id),
                            "deptName": modelData.name
                        })
                    }
                }
            }
        }

        Text {
            text: "Данные отсутствуют"
            anchors.centerIn: parent
            color: "#999999"
            visible: departmentModel.count === 0
        }
    }
}