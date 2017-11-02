import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtCharts 2.2
import "./lodash.min.js" as Lodash

Item {
    Timer {
        running: parent.visible
        triggeredOnStart: true
        interval: 10000
        repeat: true
        onTriggered: function () {
            var xhr = new XMLHttpRequest();

            xhr.onreadystatechange = function() {
                if (xhr.readyState !== XMLHttpRequest.DONE) return;

                if (xhr.status !== 200) {
                    console.log('beep', JSON.stringify(xhr.status, xhr.readyState));
                    return;
                }

                var data;

                try {
                    data = JSON.parse(xhr.responseText);
                } catch (error) {
                    return console.log(error);
                }

                if(data.success && data.result) {
                    var min_quantity = Infinity, max_quantity = 0
                    var min_rate = Infinity, max_rate = 0

                    var lowest_sell = data.result.sell[0].Rate;
                    var highest_buy = data.result.buy[0].Rate;

                    var buy_records = [], sell_records = [];


                    Lodash._.reduce(data.result.buy, function(total, record){
                        if (record.Rate < highest_buy*0.5) {
                            return total;
                        }

                        min_quantity = Math.min(total, min_quantity);
                        max_quantity = Math.max(total, max_quantity);

                        min_rate = Math.min(record.Rate, min_rate);

                        total += record.Quantity
                        buy_records.push({rate: record.Rate, value: total})

                        return total
                    }, 0)

                    Lodash._.reduce(data.result.sell, function(total, record){
                        if (record.Rate > lowest_sell*1.5) {
                            return total;
                        }

                        min_quantity = Math.min(total, min_quantity);
                        max_quantity = Math.max(total, max_quantity);

                        max_rate = Math.max(record.Rate, max_rate);

                        total += record.Quantity
                        sell_records.push({rate: record.Rate, value: total})

                        return total
                    }, 0)

                    yaxis.min = min_quantity
                    yaxis.max = max_quantity

                    xaxis.min = min_rate
                    xaxis.max = max_rate

                    buy_series.clear()
                    sell_series.clear()

                    Lodash._.each(buy_records, function (record) {
                        buy_series.append(record.rate, record.value)
                    })

                    Lodash._.each(sell_records, function (record) {
                        sell_series.append(record.rate, record.value)
                    })
                }
            }

            xhr.open('GET', 'https://bittrex.com/api/v1.1/public/getorderbook?market=' + market.base + '-' + market.target + '&type=both', true);
            xhr.send();
        }
    }
    
    Layout.minimumHeight:600
    Layout.minimumWidth:800

    ChartView {
        anchors.fill: parent
        antialiasing: true

        margins.top: 0
        margins.bottom: 0
        margins.left: 0
        margins.right: 0

        backgroundColor: "transparent"

        legend.visible: false

        ValueAxis {
            id: yaxis
            visible: false
            
            labelFormat: "%.2f"
            tickCount: 10
        }

        ValueAxis {
            id: xaxis
            visible: false

            labelsAngle: -20
            tickCount: 15
        }

        AreaSeries {
            axisY: yaxis
            axisX: xaxis

            color: "#b1d7b1"
            borderColor: "#282"
            borderWidth: 1

            useOpenGL: true

            upperSeries: LineSeries {
                pointsVisible: true

                id: buy_series
            }
        }

        AreaSeries {
            axisY: yaxis
            axisX: xaxis

            color: "#e9938a"
            borderColor: "#822"
            borderWidth: 1

            useOpenGL: true

            upperSeries: LineSeries {
                pointsVisible: true

                id: sell_series
            }
        }
    }
}
