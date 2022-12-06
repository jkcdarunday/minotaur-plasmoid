import QtQuick 2.0
import QtQuick.Controls 2.5
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Layouts 1.1

Item {
    Layout.fillWidth: true

    property string cfg_exchange

    property alias cfg_base: base_field.text
    property alias cfg_target: target_field.text
    property alias cfg_interval: interval_field.value

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        columnSpacing: 10

        Label {
            text: "Base Currency"
        }

        TextField {
            id: base_field
            placeholderText: "USDT"
            text: base_currency
        }

        Label {
            text: "Target Currency"
        }

        TextField {
            id: target_field
            placeholderText: "ETH"
            text: target_currency
        }

        Label {
            text: "Exchange"
        }

        ComboBox {
            id: current_exchange;

            function getCurrentExchangeId() {
                return current_exchange.model.indexOf(cfg_exchange);
            }

            model: ['Binance', 'Gate.io', 'Bittrex']

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
            from: 1
            to: 86400
            stepSize: 1
            textFromValue: function(value) {
                return `${value} s`;
            }
        }
    }
}
