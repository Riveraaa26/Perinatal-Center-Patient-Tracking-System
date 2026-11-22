import QtQuick
import QtQuick.Controls
import PerinatalCenter

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
    Label {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        visible: Yadro.readError.length > 0
        text: Yadro.readError
        color: "#b91c1c"
        background: Rectangle { color: "#ffffff" }
    }
}
