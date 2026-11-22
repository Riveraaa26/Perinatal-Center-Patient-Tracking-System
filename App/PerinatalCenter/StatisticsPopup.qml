import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PerinatalCenter 1.0

Popup {
    id: stats
    width: Math.min(620, parent ? parent.width - 40 : 620)
    height: Math.min(520, parent ? parent.height - 40 : 520)
    anchors.centerIn: parent
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    property var entries: []
    property string error: ""
    function refresh() {
        const result = Yadro.getOccupancyStatistics()
        error = Yadro.readError
        if (!error || error.includes("прав")) entries = result
    }
    function showStats() { refresh(); open() }
    Timer { interval: 8000; repeat: true; running: stats.visible; onTriggered: stats.refresh() }
    background: Rectangle { color: "#ffffff"; border.color: "#d1d5db"; radius: 10 }
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 20; spacing: 12
        Text { text: "Карта загруженности — статистика"; font.pixelSize: 19; font.bold: true }
        Text { text: stats.error || (stats.entries.every(d => d.free_places === 0) ? "Свободных мест нет" : "Данные по последним размещениям пациенток"); font.pixelSize: 12; color: "#666" }
        ListView {
            Layout.fillWidth: true; Layout.fillHeight: true
            clip: true; spacing: 8
            model: stats.entries
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            delegate: Rectangle {
                width: ListView.view.width; height: 72
                color: index % 2 === 0 ? "#f4f7f6" : "#ffffff"
                radius: 5
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 8; spacing: 5
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: modelData.name; Layout.fillWidth: true; font.bold: true; elide: Text.ElideRight }
                        Text { text: modelData.occupied + "/" + modelData.capacity + " занято · " + modelData.free_places + " свободно"; color: "#444" }
                    }
                    ProgressBar { Layout.fillWidth: true; from: 0; to: 100; value: modelData.percent }
                    Text { text: modelData.percent + "% загружено"; font.pixelSize: 11; color: "#666" }
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Button { text: "Обновить"; onClicked: stats.refresh() }
            Item { Layout.fillWidth: true }
            Button { text: "Закрыть"; onClicked: stats.close() }
        }
    }
}
