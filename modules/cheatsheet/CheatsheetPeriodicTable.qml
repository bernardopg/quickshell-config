import "periodic_table.js" as PTable
import QtQuick
import QtQuick.Controls

Item {
    id: root
    readonly property var elements: PTable.elements
    readonly property var series: PTable.series
    property real spacing: 6

    ScrollView {
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        ScrollBar.horizontal.policy: ScrollBar.AsNeeded

        Column {
            id: mainLayout
            width: parent.width
            spacing: root.spacing

            Repeater { // Main table rows
                model: root.elements

                delegate: Row { // Table cells
                    id: tableRow
                    spacing: root.spacing
                    required property var modelData

                    Repeater {
                        model: tableRow.modelData
                        delegate: ElementTile {
                            required property var modelData
                            element: modelData
                        }
                    }
                }
            }

            Item {
                id: gap
                implicitHeight: 20
            }

            Repeater { // Series rows
                model: root.series

                delegate: Row { // Table cells
                    id: seriesTableRow
                    spacing: root.spacing
                    required property var modelData

                    Repeater {
                        model: seriesTableRow.modelData
                        delegate: ElementTile {
                            required property var modelData
                            element: modelData
                        }
                    }
                }
            }
        }
    }
}
