import QtQuick 2.0
import QtQuick.Controls 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Layouts 1.1

Item {
    Layout.fillWidth: true

    property string cfg_exchange: "Bittrex"

    property alias cfg_base: base_field.text
    property alias cfg_target: target_field.text
    property alias cfg_orderbook: show_orderbook.checked

    Grid {
        Layout.fillWidth: true
        columns: 2

        PlasmaComponents.Label {
            text: "Base Currency"
        }

        PlasmaComponents.TextField {
            id: base_field

            placeholderText: "BTC"

            text: base_currency
        }

        PlasmaComponents.Label {
            text: "Target Currency"
        }

        PlasmaComponents.TextField {
            id: target_field

            placeholderText: "MTL"

            text: target_currency
        }

        PlasmaComponents.Label {
            text: "Exchange"
        }

        PlasmaComponents.ComboBox {
            id: current_exchange;

            model: ListModel {
                ListElement { text: "Bittrex" }
            }

            currentIndex: function() {
                return this.find(cfg_exchange);
            }
        }

        PlasmaComponents.Label {
            text: "Show Orderbook"
        }

        PlasmaComponents.CheckBox {
            id: show_orderbook;
        }
    }
}
