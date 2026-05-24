import QtQuick 6.0
import QtQuick.Controls 6.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import QtQuick.Layouts 6.0

Item {
    Layout.fillWidth: true

    property string cfg_exchange

    property alias cfg_base: base_field.text
    property alias cfg_target: target_field.text
    property alias cfg_interval: interval_field.value
    property alias cfg_showTimer: show_timer_check.checked

    GridLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 0
        columns: 2
        columnSpacing: 16
        rowSpacing: 12

        Label {
            text: "Base Currency"
        }

        TextField {
            id: base_field
            Layout.fillWidth: true
            placeholderText: "USDT"
            text: base_currency
        }

        Label {
            text: "Target Currency"
        }

        TextField {
            id: target_field
            Layout.fillWidth: true
            placeholderText: "ETH"
            text: target_currency
        }

        Label {
            text: "Exchange"
        }

        ComboBox {
            id: current_exchange
            Layout.fillWidth: true

            function getCurrentExchangeId() {
                return current_exchange.model.indexOf(cfg_exchange);
            }

            model: ['Binance', 'Gate.io', 'MEXC']

            onActivated: function(index) {
                cfg_exchange = current_exchange.currentText;
            }

            currentIndex: getCurrentExchangeId()
        }

        Label {
            text: "Interval"
        }

        SpinBox {
            id: interval_field
            Layout.fillWidth: true
            from: 1
            to: 86400
            stepSize: 1
            textFromValue: value => `${value} s`
            valueFromText: text => parseInt(text)
        }

        Label {
            text: "Show Timer"
        }

        CheckBox {
            id: show_timer_check
        }
    }
}
