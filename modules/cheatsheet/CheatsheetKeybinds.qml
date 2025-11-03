pragma ComponentBehavior: Bound

import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    readonly property var keybinds: HyprlandKeybinds.keybinds
    property real spacing: 16
    property real titleSpacing: 6
    property real padding: 10
    property real sectionMaxWidth: 420

    // Let the container size adapt but not explode
    implicitWidth: Math.min(content.implicitWidth + padding * 2, 1600)
    implicitHeight: Math.min(content.implicitHeight + padding * 2, 1200)

    property var keyBlacklist: ["Super_L"]
    property var keySubstitutions: ({
        "Super": "󰖳",
        "mouse_up": "Scroll ↓",
        "mouse_down": "Scroll ↑",
        "mouse:272": "LMB",
        "mouse:273": "RMB",
        "mouse:275": "MouseBack",
        "Slash": "/",
        "Hash": "#",
        "Return": "Enter",
    })

    ScrollView {
        id: scroller
        anchors.fill: parent
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        ScrollBar.horizontal.policy: ScrollBar.AsNeeded

        Column {
            id: content
            width: scroller.width
            spacing: 10
            
            // Search/filter
            Frame {
                padding: 6
                width: content.width - padding * 2
                anchors.horizontalCenter: parent.horizontalCenter
                background: Rectangle { radius: 8; color: Appearance.colors.colLayer0 }
                RowLayout {
                    anchors.fill: parent
                    spacing: 8
                    MaterialSymbol { text: "search"; color: Appearance.colors.colOnLayer0 }
                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: Translation.tr("Filtrar atalhos…")
                    }
                }
            }

            // Sections in a responsive flow
            Flow {
                id: sectionFlow
                width: content.width - padding * 2
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: root.spacing

                Repeater {
                    model: keybinds.children

                    delegate: Item { // Section card wrapper
                        required property var modelData
                        width: Math.min(root.sectionMaxWidth, sectionFlow.width)
                        implicitWidth: width
                        implicitHeight: card.implicitHeight

                        // Hide sections with no matches
                        visible: {
                            const q = (searchField.text || "").toLowerCase();
                            if (!q) return true;
                            const name = (modelData.name || "").toLowerCase();
                            for (let i = 0; i < modelData.keybinds.length; i++) {
                                const kb = modelData.keybinds[i];
                                const mods = (kb.mods || []).join(" ");
                                const blob = (name + " " + mods + " " + kb.key + " " + (kb.comment || "")).toLowerCase();
                                if (blob.indexOf(q) !== -1) return true;
                            }
                            return false;
                        }

                        Rectangle { // Card
                            id: card
                            width: parent.width
                            radius: 10
                            color: Appearance.colors.colLayer0
                            border.width: 1
                            border.color: Appearance.colors.colLayer0Border
                            
                            Column {
                                id: sectionColumn
                                anchors.margins: 10
                                anchors.fill: parent
                                spacing: root.titleSpacing

                                StyledText {
                                    id: sectionTitle
                                    font {
                                        family: Appearance.font.family.title
                                        pixelSize: Math.min(Appearance.font.pixelSize.title, 22)
                                        variableAxes: Appearance.font.variableAxes.title
                                    }
                                    color: Appearance.colors.colOnLayer0
                                    text: modelData.name
                                }

                                GridLayout {
                                    id: keybindGrid
                                    columns: sectionColumn.width > 360 ? 2 : 1
                                    columnSpacing: 6
                                    rowSpacing: 6

                                    Repeater {
                                        model: {
                                            const result = [];
                                            const q = (searchField.text || "").toLowerCase();
                                            for (let i = 0; i < modelData.keybinds.length; i++) {
                                                const keybind = modelData.keybinds[i];
                                                if (q) {
                                                    const mods = (keybind.mods || []).join(" ");
                                                    const blob = (modelData.name + " " + mods + " " + keybind.key + " " + (keybind.comment || "")).toLowerCase();
                                                    if (blob.indexOf(q) === -1)
                                                        continue;
                                                }
                                                result.push({ type: "keys", mods: keybind.mods, key: keybind.key });
                                                result.push({ type: "comment", comment: keybind.comment });
                                            }
                                            return result;
                                        }
                                        delegate: Item {
                                            required property var modelData
                                            implicitWidth: keybindLoader.implicitWidth
                                            implicitHeight: keybindLoader.implicitHeight

                                            Loader {
                                                id: keybindLoader
                                                sourceComponent: (modelData.type === "keys") ? keysComponent : commentComponent
                                            }

                                            Component {
                                                id: keysComponent
                                                Row {
                                                    spacing: 4
                                                    Repeater {
                                                        model: modelData.mods
                                                        delegate: KeyboardKey {
                                                            required property var modelData
                                                            key: keySubstitutions[modelData] || modelData
                                                        }
                                                    }
                                                    StyledText {
                                                        id: keybindPlus
                                                        visible: !keyBlacklist.includes(modelData.key) && modelData.mods.length > 0
                                                        text: "+"
                                                    }
                                                    KeyboardKey {
                                                        id: keybindKey
                                                        visible: !keyBlacklist.includes(modelData.key)
                                                        key: keySubstitutions[modelData.key] || modelData.key
                                                        color: Appearance.colors.colOnLayer0
                                                    }
                                                }
                                            }

                                            Component {
                                                id: commentComponent
                                                Item {
                                                    id: commentItem
                                                    implicitWidth: commentText.implicitWidth + 8 * 2
                                                    implicitHeight: commentText.implicitHeight
                                                    
                                                    StyledText {
                                                        id: commentText
                                                        anchors.centerIn: parent
                                                        wrapMode: Text.WordWrap
                                                        maximumLineCount: 3
                                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                                        text: modelData.comment
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
