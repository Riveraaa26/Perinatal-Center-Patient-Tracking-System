import QtQuick
import QtQuick.Controls

ApplicationWindow
{
    id: window
    visible: true
    width: 1000
    height: 700
    title: qsTr("Перинатальный центр")
    color: "#ffffff"

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: "LoginPage.qml"
    }
}