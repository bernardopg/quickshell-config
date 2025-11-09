import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root
    property string title
    property string icon: ""
    default property alias data: sectionContent.data

    Layout.fillWidth: true
    spacing: 8

    RowLayout {
        spacing: 8
        OptionalMaterialSymbol {
            icon: root.icon
            iconSize: Appearance.font.pixelSize.huge
        }
        StyledText {
            text: root.title
            font.pixelSize: Appearance.font.pixelSize.large
            font.weight: Font.Medium
            color: Appearance.colors.colOnSecondaryContainer
        }
    }

    ColumnLayout {
        id: sectionContent
        Layout.fillWidth: true
        spacing: 6

    }
}
