import QtQuick 6.0
import QtQuick.Layouts 6.0
import org.kde.plasma.components 3.0 as PlasmaComponents
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

    ColumnLayout {
        id: main_column

        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
            left: parent.left
            leftMargin: 5
            rightMargin: 5
        }

        Layout.maximumWidth: parent.width

        RowLayout {
            id: topSection
            spacing: 3

            clip: true
            Layout.maximumWidth: parent.width

            PlasmaComponents.Label {
                id: base

                Layout.fillWidth: true
                Layout.preferredWidth: parent.width / 2 - exchange.width

                text: market.display_base + '-' + market.display_target
                elide: Text.ElideRight
                font.weight: Font.Bold
                font.pointSize: 8
            }

            PlasmaComponents.Label {
                id: exchange

                horizontalAlignment: Text.AlignHCenter

                text: market.display_exchange
                elide: Text.ElideRight
            }

            PlasmaComponents.Label {
                id: last_update

                Layout.fillWidth: true
                Layout.preferredWidth: parent.width / 2 - exchange.width
                horizontalAlignment: Text.AlignRight

                text: market_value.last_update
                elide: Text.ElideRight
                font.pointSize: 8

                color: market_value.update_failed ? '#F00' : PlasmaCore.Theme.textColor
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

            Layout.preferredHeight: topSection.height

            PlasmaComponents.Label {
                id: low
                text: "L: " + market_value.low
                font.pointSize: 8
            }

            Rectangle {
                Layout.fillWidth: true
            }

            PlasmaComponents.Label {
                id: high
                text: "H: " + market_value.high
                font.pointSize: 8
            }
        }
    }
}
