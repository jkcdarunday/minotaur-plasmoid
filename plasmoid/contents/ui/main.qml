import QtQuick 6.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

PlasmoidItem {
    id: root

    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}

    readonly property bool isConstrained: (plasmoid.formFactor == PlasmaCore.Types.Vertical || plasmoid.formFactor == PlasmaCore.Types.Horizontal)

    preferredRepresentation: isConstrained ? compactRepresentation : fullRepresentation
}
