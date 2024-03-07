import QtQuick 6.0
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
         name: i18n("General")
         icon: "preferences-system-windows"
         source: "config/general.qml"
    }
}
