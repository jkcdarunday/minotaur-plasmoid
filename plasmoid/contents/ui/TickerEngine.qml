import QtQuick 6.0
import QtQuick.Layouts 6.0
import org.kde.plasma.components 3.0 as PlasmaComponents
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
            const urls = [];

            if (exchange.url) {
                urls.push(exchange.url);
            }

            if (exchange.urls) {
                exchange.urls.forEach(url => urls.push(url));
            }

            const processedUrls = urls.map(
                (url) => url.replace('{base}', market.base).replace('{target}', market.target)
            );

            Promise.all(processedUrls.map(
                (url) => request({
                    url: url,
                    success: exchange.parser,
                    timeout: retriever.interval,
                }).then((data) => JSON.parse(data))
            ))
                .then(exchange.parser)
                .catch(
                    function(error) {
                        console.log('Retrieval returned error:', error)
                        market_value.update_failed = true
                        throw error;
                    }
                );
        }

        function request (options) {
            return new Promise((resolve, reject) => {
                const requestId = ++retriever.lastRequestId;

                console.log(`Doing request ${requestId}: ${options.url}`);

                var xhr = new XMLHttpRequest();

                xhr.timeout = Math.min(() => reject('Timed out'), 5000);
                xhr.onreadystatechange = function() {
                    if (xhr.readyState !== XMLHttpRequest.DONE) {
                        return;
                    }

                    console.log(`Request ${requestId} finished`);

                    if (xhr.status == 200) {
                        return resolve(xhr.responseText);
                    }

                    return reject(xhr.responseText);
                }

                xhr.open(options.method || 'GET', options.url, true);

                xhr.send();
            })
        }
    }

    QtObject {
        id: market_functions
        property var markets: {
            "Bittrex": {
                urls: [
                    'https://api.bittrex.com/v3/markets/{target}-{base}/summary',
                    'https://api.bittrex.com/v3/markets/{target}-{base}/ticker',
                ],
                parser: function(results) {
                    const data = results[0];
                    const lastPrice = results[1].lastTradeRate;

                    if (!data.symbol || !lastPrice) {
                        console.log('Bittrex returned no symbol or last price');
                        return
                    }

                    market_value.last = lastPrice
                    market_value.high = data.high
                    market_value.low = data.low

                    market_value.day_change = data.percentChange

                    market_value.last_update = new Date().toLocaleTimeString()

                    market_value.update_failed = false

                    market.display_exchange = "Bittrex"

                    var market_name = data.symbol.split('-')

                    market.display_base = market_name[0]
                    market.display_target = market_name[1]
                }
            },
            "Binance": {
                url: 'https://api.binance.com/api/v3/ticker/24hr?symbol={target}{base}',
                parser: function(results) {
                    const data = results[0];

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
            },
            "Gate.io": {
                url: 'https://api.gateio.ws/api/v4/spot/tickers?currency_pair={target}_{base}',
                parser: function(results) {
                    const data = results[0][0];

                    if (!data.last) {
                        console.log('Gate.io returned unsuccessful');
                        return
                    }

                    market_value.last = data.last
                    market_value.high = data.high_24h
                    market_value.low = data.low_24h
                    market_value.day_change = data.change_percentage
                    market_value.last_update = new Date().toLocaleTimeString()

                    market_value.update_failed = false

                    market.display_exchange = 'Gate.io'

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
