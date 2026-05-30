import QtQuick 6.0
import QtQuick.Layouts 6.0
import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
    Layout.minimumWidth: 220
    Layout.minimumHeight: 70

    property QtObject market;
    property QtObject market_value;

    Component.onCompleted: function () {
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

            RowLayout {
                spacing: 3

                MouseArea {
                    id: marketNameArea
                    Layout.preferredWidth: base.implicitWidth
                    Layout.preferredHeight: base.implicitHeight
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (market.trade_url) {
                            Qt.openUrlExternally(market.trade_url);
                        }
                    }

                    PlasmaComponents.Label {
                        id: base

                        text: market.display_base + '-' + market.display_target
                        elide: Text.ElideRight
                        font.weight: Font.Bold
                        font.pointSize: 7
                    }
                }

                PieTimer {
                    id: pieTimer
                    visible: plasmoid.configuration.showTimer
                    totalInterval: engine.retrieverRef.interval
                    elapsedTime: {
                        var elapsed = (Date.now() - engine.retrieverRef.lastTriggered) % engine.retrieverRef.interval;
                        return Math.max(0, elapsed);
                    }

                    Layout.preferredWidth: 8
                    Layout.preferredHeight: 8
                    Layout.alignment: Qt.AlignVCenter
                    Layout.maximumWidth: visible ? 8 : 0
                    Layout.maximumHeight: visible ? 8 : 0
                }
            }

            Rectangle {
                Layout.fillWidth: true
            }

            PlasmaComponents.Label {
                id: exchange

                horizontalAlignment: Text.AlignHCenter

                text: market.display_exchange
                elide: Text.ElideRight
            }

            Rectangle {
                Layout.fillWidth: true
            }

            PlasmaComponents.Label {
                id: last_update

                horizontalAlignment: Text.AlignRight

                text: market_value.last_update
                elide: Text.ElideRight
                font.pointSize: 7

                states: State {
                    name: "updateFailed"
                    when: market_value.update_failed

                    PropertyChanges {
                        target: last_update
                        color: "#F00"
                    }
                }
            }
        }

        RowLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true

            PlasmaComponents.Label {
                id: value

                Layout.fillHeight: true
                Layout.fillWidth: true

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

                verticalAlignment: Text.AlignVCenter
            }

            ColumnLayout {
                id: value_label
                Layout.preferredHeight: value.contentHeight * 0.6
                Layout.alignment: Qt.AlignVCenter
                spacing: 0

                PlasmaComponents.Label {
                    text: market.display_base
                    Layout.alignment: Qt.AlignTop
                    font.pointSize: value.contentHeight > 50 ? 10 : 8
                }

                PlasmaComponents.Label {
                    id: change
                    Layout.alignment: Qt.AlignBottom
                    color: market_value.day_change > 0
                            ? "#090"
                            : market_value.day_change < 0
                                ? "#900"
                                : "#666"
                    text: Number(market_value.day_change)
                            .toFixed(2)
                            .toLocaleString() + "%"
                    font.pointSize: value.contentHeight > 50 ? 10 : 8
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
