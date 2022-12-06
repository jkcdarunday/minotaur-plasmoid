import QtQuick 2.4
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    Layout.minimumWidth: 220
    Layout.minimumHeight: 70

    property QtObject market;
    property QtObject market_value;

    Component.onCompleted: function () {
        last_update.default_color = last_update.color

        market = engine.market
        market_value = engine.market_value
    }

    TickerEngine {
        id: engine
    }

    GridLayout {
        id: main_column

        columns: 1

        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
            left: parent.left
            leftMargin: 5
            rightMargin: 5
        }

        RowLayout {
            spacing: 3

            PlasmaComponents.Label {
                id: base
                text: market.display_base + '-' + market.display_target

                font.weight: Font.Bold
            }

            PlasmaComponents.Label {
                text: "|"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            PlasmaComponents.Label {
                id: exchange
                text: market.display_exchange
            }

            PlasmaComponents.Label {
                text: "|"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            PlasmaComponents.Label {
                id: last_update
                text: market_value.last_update

                color: market_value.update_failed ? '#F00' : PlasmaCore.ColorScope.textColor

                property string default_color: ""
            }
        }

        Row {
            Layout.fillHeight: true
            Layout.fillWidth: true

            PlasmaComponents.Label {
                id: value

                height: parent.height
                width: parent.width - value_label.width

                text: market_value.last
                    .toFixed(
                        Math.max(9 - market_value.last.toFixed(0).length, 0)
                    )
                    .toLocaleString()

                font.pointSize: 100
                minimumPointSize: 24

                fontSizeMode: Text.Fit

                TextMetrics {
                    id: value_metrics
                    font: value.font
                    text: value.text
                }
            }

            Column {
                id: value_label

                height: value.contentHeight
                anchors.left: value.left
                anchors.leftMargin: value.contentWidth + 5
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter

                PlasmaComponents.Label {
                    text: market.display_base
                    height: parent.height * 3 / 5
                }

                PlasmaComponents.Label {

                    id: change
                    color: market_value.day_change > 0
                            ? "#090"
                            : market_value.day_change < 0
                                ? "#900"
                                : "#666"
                    text: Number(market_value.day_change)
                            .toFixed(2)
                            .toLocaleString() + "%"
                    height: parent.height * 2 / 5
                }
            }
        }

        RowLayout {
            spacing: 10

            PlasmaComponents.Label {
                id: low
                text: "L:" + market_value.low
            }

            Rectangle {
                Layout.fillWidth: true
            }

            PlasmaComponents.Label {
                id: high
                text: "H:" + market_value.high
            }
        }
    }
}
