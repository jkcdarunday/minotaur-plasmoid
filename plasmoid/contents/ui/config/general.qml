import QtQuick 2.0
import QtQuick.Controls 1.1
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Layouts 1.1

Item {
    Layout.fillWidth: true

    property string base_currency: "BTC"
    property string target_currency: "MTL"
    property string exchange: "Bittrex"

    Component.onCompleted: function() {
        base_currency = plasmoid.configuration.base
        target_currency = plasmoid.configuration.target
        exchange = plasmoid.configuration.exchange

        console.log('Loaded config page');
    }

    Grid {
        Layout.fillWidth: true
        columns: 2

        PlasmaComponents.Label {
            text: "Base Currency"
        }

        PlasmaComponents.TextField {
            placeholderText: "BTC"

            text: base_currency

            onTextChanged: function() {
                plasmoid.configuration.base = this.text
            }
        }

        PlasmaComponents.Label {
            text: "Target Currency"
        }

        PlasmaComponents.TextField {
            placeholderText: "MTL"

            text: target_currency

            onTextChanged: function() {
                plasmoid.configuration.target = this.text
            }
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
                return this.find(exchange);
            }

            onCurrentTextChanged: function() {
                plasmoid.configuration.exchange = this.currentText
            }
        }
    }
}
