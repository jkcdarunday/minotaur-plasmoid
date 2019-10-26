import QtQuick 2.4
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Layouts 1.1

Item {
    id: root

    Layout.minimumWidth: main_column.width
    Layout.minimumHeight: main_column.height
    height: main_column.height

    Connections {
        target: plasmoid.configuration
        onExchangeChanged: configChanged()
        onTargetChanged: configChanged()
        onBaseChanged: configChanged()

        function configChanged () {
            retriever.restart()
        }
    }

    Component.onCompleted: function () {
        last_update.default_color = last_update.color

        retriever.start()
    }


    Timer {
        id: retriever

        running: false
        triggeredOnStart: true
        interval: plasmoid.configuration.interval
        repeat: true
        property int lastRequestId: 0

        onTriggered: function () {
            var exchange = market_functions.markets[market.exchange];
            var url = exchange.url.replace('{base}', market.base).replace('{target}', market.target)

            request({
                url: url,
                success: exchange.parser,
                timeout: retriever.interval,
                error: function(error) {
                    console.log('Retrieval returned error:', error)
                    last_update.color = '#F00'
                }
            });
        }

        function request (options) {
            const requestId = ++retriever.lastRequestId;

            console.log(`Doing request ${requestId}: ${options.url}`);

            var xhr = new XMLHttpRequest();

            xhr.timeout = Math.min(options.timeout, 5000);
            xhr.onreadystatechange = function() {
                if (xhr.readyState !== XMLHttpRequest.DONE) {
                    return;
                }

                console.log(`Request ${requestId} finished`);

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
                url: 'https://bittrex.com/api/v1.1/public/getmarketsummary?market={base}-{target}',
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

                    const prevDay = data.result[0].PrevDay;
                    market_value.day_change = 100.0 * (market_value.last - prevDay) / market_value.last

                    market_value.last_update = new Date().toLocaleTimeString()

                    last_update.color = last_update.default_color

                    market.display_exchange = "Bittrex"

                    var market_name = data.result[0].MarketName.split('-')

                    market.display_base = market_name[0]
                    market.display_target = market_name[1]
                }
            },
            "Binance": {
                url: 'https://api.binance.com/api/v3/ticker/24hr?symbol={target}{base}',
                parser: function(result) {
                    var data

                    try {
                        data = JSON.parse(result)
                    } catch (exception) {
                        console.log(exception)
                        return
                    }

                    if (!data.lastPrice) {
                        console.log('Binance returned unsuccessful');
                        return
                    }

                    market_value.last = data.lastPrice
                    market_value.high = data.highPrice
                    market_value.low = data.lowPrice
                    market_value.day_change = data.priceChangePercent
                    market_value.last_update = new Date().toLocaleTimeString()

                    last_update.color = last_update.default_color

                    market.display_exchange = 'Binance'

                    market.display_base = market.base
                    market.display_target = market.target
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
        property double day_change: 0
        property string last_update: ""

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

            PlasmaComponents.Label {
                text: "|"
            }

            PlasmaComponents.Label {
                id: last_update
                text: market_value.last_update

                property string default_color: ""
            }
        }

        Row {
            spacing: 10

            height: value_metrics.tightBoundingRect.height

            PlasmaComponents.Label {
                id: value
                text: market_value.last
                    .toFixed(
                        Math.max(9 - market_value.last.toFixed(0).length, 0)
                    )
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
