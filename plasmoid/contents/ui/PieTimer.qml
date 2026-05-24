import QtQuick 6.0

Item {
    id: root

    property real totalInterval: 60000  // milliseconds
    property real elapsedTime: 0        // milliseconds

    width: 8
    height: 8

    Timer {
        id: updateTimer
        interval: 250  // Update every 250ms for smooth animation with less overhead
        running: true
        repeat: true

        onTriggered: {
            // Increment elapsed time
            root.elapsedTime = (root.elapsedTime + interval) % root.totalInterval
        }
    }

    Canvas {
        id: pieCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            var centerX = width / 2;
            var centerY = height / 2;
            var radius = Math.min(width, height) / 2 - 0.5;

            // Clear canvas
            ctx.fillStyle = "transparent";
            ctx.clearRect(0, 0, width, height);

            // Calculate progress angle (0 to 2π)
            var progress = root.elapsedTime / root.totalInterval;
            var angle = (1 - progress) * Math.PI * 2;

            // Draw filled pie (monotone gray)
            ctx.fillStyle = "#888";
            ctx.beginPath();
            ctx.moveTo(centerX, centerY);
            ctx.arc(centerX, centerY, radius, -Math.PI / 2, -Math.PI / 2 - angle, true);
            ctx.lineTo(centerX, centerY);
            ctx.fill();
        }
    }

    onElapsedTimeChanged: {
        pieCanvas.requestPaint();
    }
}
