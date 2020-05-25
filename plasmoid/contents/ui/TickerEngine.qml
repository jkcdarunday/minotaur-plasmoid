import QtQuick 2.4
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0

Item {

    property QtObject market_value: market_value
    property QtObject market: market

    Component.onCompleted: function () {
        retriever.start()
    }

    Connections {
        target: plasmoid.configuration
        onExchangeChanged: configChanged()
        onTargetChanged: configChanged()
        onBaseChanged: configChanged()

        function configChanged () {
            retriever.restart()
        }
    }

//     CompactTickerView {
//         id: compactView
//         market_value: market_value
//         market: market
// 
//         anchors {
//             top: parent.top
//             right: parent.right
//             bottom: parent.bottom
//             left: parent.left
//         }
//     }
// 
//     TickerView {
//         id: fullView
//         market_value: market_value
//         market: market
// 
//         anchors {
//             top: parent.top
//             right: parent.right
//             bottom: parent.bottom
//             left: parent.left
//         }
//     }


    Timer {
        id: retriever

        running: false
        triggeredOnStart: true
        interval: plasmoid.configuration.interval * 1000
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
                    market_value.update_failed = true
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

                    market_value.update_failed = false

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

                    market_value.update_failed = false

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
        property bool update_failed: false

    }
}
