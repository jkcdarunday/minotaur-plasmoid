import QtQuick 2.4
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore


Item {
    Layout.minimumWidth: main_row.width + 10
    property QtObject market;
    property QtObject market_value;

    TickerEngine {
        id: engine
    }

    Component.onCompleted: function () {
        market = engine.market
        market_value = engine.market_value
    }

    anchors {
        top: parent.top
        right: parent.right
        bottom: parent.bottom
        left: parent.left
        leftMargin: 5
        rightMargin: 5
    }


    Row {
        id: main_row
        spacing: 3
        anchors {
            top: parent.top
            bottom: parent.bottom
        }

        PlasmaComponents.Label {
            id: display
            text: market_value.last.toFixed(Math.max(9 - market_value.last.toFixed(0).length, 0)).toLocaleString()
            font.pointSize: 16
            minimumPointSize: 16
        }
        PlasmaComponents.Label {
            id: base
            anchors.baseline: display.baseline
            font.pointSize: 12
            minimumPointSize: 12
            text: market.display_base
            font.weight: Font.Bold
        }
        PlasmaComponents.Label {
            anchors.baseline: display.baseline
            font.pointSize: 12
            minimumPointSize: 12
            text: '/'
        }
        PlasmaComponents.Label {
            anchors.baseline: display.baseline
            font.pointSize: 12
            minimumPointSize: 12
            text: market.display_target
        }
    }
}
