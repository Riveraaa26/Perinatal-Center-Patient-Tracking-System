import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PerinatalCenter 1.0

Item {
    id: chambersView

    property int deptId: -1
    property string deptName: ""

    Component.onCompleted: {
        // Загружаем палаты
        chamberListModel.model = Yadro.getChambersByDepartment(chambersView.deptId)
    }

    // Заголовок (название отделения, например "Родовое")
    Text {
        id: pageTitle
        text: chambersView.deptName
        font.pixelSize: 22
        font.bold: true
        color: "#333333"
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
    }

    // Кнопка "Назад" (возврат к отделениям)
    Button {
        id: backButton
        text: "Назад"
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 20
        implicitWidth: 100
        implicitHeight: 35
        font.pixelSize: 14
        onClicked: {
            stackView.pop()
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
            id: chamberListModel
            anchors.fill: parent
            anchors.margins: 10
            clip: true
            highlightFollowsCurrentItem: false
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded; width: 10 }

            header: Rectangle {
                width: chamberListModel.width - 10
                height: 35
                color: "#f0f0f0"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10

                    Text { text: "Номер"; font.bold: true; Layout.preferredWidth: 60; font.pixelSize: 14 }
                    Text { text: "Тип"; font.bold: true; Layout.preferredWidth: 120; font.pixelSize: 14 }
                    Text { text: "Всего мест"; font.bold: true; Layout.preferredWidth: 100; font.pixelSize: 14 }
                    Text { text: "Свободно"; font.bold: true; Layout.fillWidth: true; font.pixelSize: 14 }
                }
            }

            delegate: Rectangle {
                width: chamberListModel.width - 10
                height: 40
                color: index % 2 === 0 ? "#ffffff" : "#f9f9f9"
                border.color: "#eeeeee"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10

                    Text { text: modelData.number; Layout.preferredWidth: 60; font.pixelSize: 14 }

                    Text {
                        text: modelData.disease ? "Инкубатор" : "Обычная"
                        Layout.preferredWidth: 120
                        font.pixelSize: 14
                        color: modelData.disease ? "#d9534f" : "#333333"
                    }

                    Text { text: modelData.capacity; Layout.preferredWidth: 100; font.pixelSize: 14 }

                    Text {
                        text: modelData.free_places
                        Layout.fillWidth: true
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
            visible: chamberListModel.count === 0
        }
    }
}