import QtQuick 2.4
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Layouts 1.1

Item {
    id: root

    Layout.minimumWidth: main_column.width
    Layout.minimumHeight: main_column.height
    height: main_column.height


    Timer {
        running: true
        triggeredOnStart: true
        interval: 5000
        repeat: true
        onTriggered: function () {
            console.log('Doing request');

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
                if (xhr.readyState !== XMLHttpRequest.DONE) {
                    return;
                }

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

                    market.display_exchange = "Bittrex"

                    var market_name = data.result[0].MarketName.split('-')

                    market.display_base = market_name[0]
                    market.display_target = market_name[1]
                }
            }
        }
    }

    QtObject {
        id: market
        property string base: plasmoid.configuration.base || "BTC"
        property string target: plasmoid.configuration.target || "ETH"
        property string exchange: plasmoid.configuration.exchange || "Bittrex"
        property string display_base: ""
        property string display_target: ""
        property string display_exchange: ""
    }

    QtObject {
        id: market_value
        property double last: 0.0
        property double high: 0.1
        property double low: 0.0
        property double last_day: 0.1
        property double day_change: (market_value.last - market_value.last_day)/market_value.last

    }

    Column {
        id: main_column

        spacing: 5

        Row {
            spacing: 3

            PlasmaComponents.Label {
                id: base
                text: market.display_base + '-' + market.display_target

                font.weight: Font.Bold
            }

            PlasmaComponents.Label {
                text: "|"
            }

            PlasmaComponents.Label {
                id: exchange
                text: market.display_exchange
            }
        }

        Row {
            spacing: 10

            height: value_metrics.tightBoundingRect.height

            PlasmaComponents.Label {
                id: value
                text: Number(market_value.last)
                    .toFixed(8)
                    .toLocaleString()

                font.pointSize: 24

                height: parent.height

                TextMetrics {
                    id: value_metrics
                    font: value.font
                    text: value.text
                }
            }



            Column {
                height: parent.height
                spacing: 0

                PlasmaComponents.Label {
                    text: market.display_base
                    font.pixelSize: parent.height * 3 / 5
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
                    font.pixelSize: parent.height * 2 / 5
                    height: parent.height * 2 / 5
                }
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
