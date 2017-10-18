import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Layouts 1.1

Item {
    id: root

    Layout.minimumWidth: main_column.width
    Layout.minimumHeight: main_column.height


    Timer {
        running: true
        triggeredOnStart: true
        interval: 5000
        onTriggered: function () {
            var exchange = market_functions.markets[market.exchange];
            var url = exchange.url.replace('{}', market.base + '-' + market.target)


            console.log(url);

            request({
                url: url,
                success: exchange.parser,
                error: function(error) {
                    console.log('Retrieval returned error:', error)
                }
            });
        }

        function request (options) {
            var xhr = new XMLHttpRequest();

            xhr.onreadystatechange = function() {
                if (xhr.status == 200) {
                   return options.success(xhr.responseText);
                }

                return options.error(xhr.responseText);
            }

            xhr.open(options.method || 'GET', options.url, true);

            xhr.send();
        }
    }

    QtObject {
        id: market_functions
        property var markets: {
            "Bittrex": {
                url: 'https://bittrex.com/api/v1.1/public/getmarketsummary?market={}',
                parser: function(result) {
                    var data

                    try {
                        data = JSON.parse(result)
                    } catch (exception) {
                        console.log(exception)
                        return
                    }

                    if (!data.success) {
                        console.log('Bittrex returned unsuccessful');
                        return
                    }

                    market_value.last = data.result[0].Last
                    market_value.high = data.result[0].High
                    market_value.low = data.result[0].Low
                    market_value.last_day = data.result[0].PrevDay
                }
            }
        }
    }

    QtObject {
        id: market
        property string base: "BTC"
        property string target: "ETH"
        property string exchange: "Bittrex"
    }

    QtObject {
        id: market_value
        property double last: 1000.0
        property double high: 1001.0
        property double low: 999.0
        property double last_day: 999.0

    }

    Column {
        id: main_column

        Row {
            spacing: 10

            PlasmaComponents.Label {
                id: base
                text: market.base
            }

            PlasmaComponents.Label {
                id: target
                text: market.target
            }

            PlasmaComponents.Label {
                id: exchange
                text: market.exchange
            }
        }

        Row {
            spacing: 10

            PlasmaComponents.Label {
                id: value
                text: Number(market_value.last).toLocaleString()

                font.pointSize: 24
            }

            PlasmaComponents.Label {
                id: change
                text: Number(market_value.last / market_value.last_day)
                        .toFixed(2)
                        .toLocaleString() + "%"

                anchors.top: parent.top
                anchors.bottom: parent.bottom
            }
        }

        Row {
            spacing: 10

            PlasmaComponents.Label {
                id: low
                text: "L:" + market_value.low
            }

            PlasmaComponents.Label {
                id: high
                text: "H:" + market_value.high
            }
        }
    }
}
