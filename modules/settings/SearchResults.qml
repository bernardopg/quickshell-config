import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.services as Services
import qs.modules.common as Common
import qs.modules.common.widgets
import qs.modules.common.functions as CF

Item {
    id: root

    property string searchQuery: ""
    property var pages: []
    signal resultClicked(int pageIndex)

    // Search results data structure
    property var searchableContent: [
        {
            pageIndex: 0,
            pageName: "Quick",
            items: [
                { text: "quick settings", keywords: ["quick", "fast", "toggle", "enable", "disable"] },
                { text: "modules", keywords: ["module", "component", "feature"] },
                { text: "bar", keywords: ["bar", "panel", "top"] },
                { text: "dock", keywords: ["dock", "launcher", "apps"] },
                { text: "sidebar", keywords: ["sidebar", "side", "panel"] }
            ]
        },
        {
            pageIndex: 1,
            pageName: "General",
            items: [
                { text: "shell behavior", keywords: ["shell", "behavior", "general"] },
                { text: "startup", keywords: ["startup", "autostart", "boot"] },
                { text: "windows", keywords: ["window", "windows", "titlebar", "decorations"] },
                { text: "animations", keywords: ["animation", "transition", "effect"] },
                { text: "performance", keywords: ["performance", "speed", "optimization"] }
            ]
        },
        {
            pageIndex: 2,
            pageName: "Bar",
            items: [
                { text: "bar position", keywords: ["bar", "position", "top", "bottom"] },
                { text: "bar widgets", keywords: ["widget", "component", "element"] },
                { text: "workspaces", keywords: ["workspace", "desktop", "virtual"] },
                { text: "system tray", keywords: ["tray", "systray", "icons"] },
                { text: "clock", keywords: ["clock", "time", "date"] },
                { text: "battery", keywords: ["battery", "power", "charge"] },
                { text: "media controls", keywords: ["media", "music", "player", "mpris"] }
            ]
        },
        {
            pageIndex: 3,
            pageName: "Background",
            items: [
                { text: "wallpaper", keywords: ["wallpaper", "background", "image"] },
                { text: "blur", keywords: ["blur", "effect", "backdrop"] },
                { text: "transparency", keywords: ["transparency", "opacity", "alpha"] },
                { text: "animations", keywords: ["animation", "transition", "effect"] }
            ]
        },
        {
            pageIndex: 4,
            pageName: "Interface",
            items: [
                { text: "theme", keywords: ["theme", "color", "appearance"] },
                { text: "colors", keywords: ["color", "palette", "scheme"] },
                { text: "fonts", keywords: ["font", "typography", "text"] },
                { text: "rounding", keywords: ["rounding", "corner", "radius", "border"] },
                { text: "material design", keywords: ["material", "m3", "design"] },
                { text: "dark mode", keywords: ["dark", "light", "mode", "theme"] }
            ]
        },
        {
            pageIndex: 5,
            pageName: "Services",
            items: [
                { text: "ai service", keywords: ["ai", "artificial", "intelligence", "llm"] },
                { text: "translation", keywords: ["translation", "translate", "language"] },
                { text: "weather", keywords: ["weather", "forecast", "temperature"] },
                { text: "network", keywords: ["network", "wifi", "internet", "connection"] },
                { text: "bluetooth", keywords: ["bluetooth", "bt", "wireless"] },
                { text: "audio", keywords: ["audio", "sound", "volume", "speaker"] },
                { text: "notifications", keywords: ["notification", "notify", "alert"] }
            ]
        },
        {
            pageIndex: 6,
            pageName: "Advanced",
            items: [
                { text: "debug mode", keywords: ["debug", "log", "verbose"] },
                { text: "experimental features", keywords: ["experimental", "beta", "testing"] },
                { text: "config file", keywords: ["config", "configuration", "settings", "file"] },
                { text: "reset settings", keywords: ["reset", "restore", "default", "clear"] },
                { text: "import export", keywords: ["import", "export", "backup", "restore"] }
            ]
        },
        {
            pageIndex: 7,
            pageName: "About",
            items: [
                { text: "version", keywords: ["version", "release", "build"] },
                { text: "credits", keywords: ["credits", "author", "developer"] },
                { text: "license", keywords: ["license", "copyright", "legal"] },
                { text: "github", keywords: ["github", "repository", "source"] }
            ]
        }
    ]

    // Filter results based on search query
    property var filteredResults: {
        if (!searchQuery || searchQuery.length < 2) return []

        const query = searchQuery.toLowerCase()
        const results = []

        for (const page of searchableContent) {
            for (const item of page.items) {
                // Check if query matches text or keywords
                const textMatch = item.text.toLowerCase().includes(query)
                const keywordMatch = item.keywords.some(keyword =>
                    keyword.toLowerCase().includes(query)
                )

                if (textMatch || keywordMatch) {
                    results.push({
                        pageIndex: page.pageIndex,
                        pageName: page.pageName,
                        itemText: item.text,
                        // Calculate relevance score
                        relevance: textMatch ? 10 : 5
                    })
                }
            }
        }

        // Sort by relevance
        results.sort((a, b) => b.relevance - a.relevance)

        return results
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: 20
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 12

            // Search header
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                StyledText {
                    text: root.searchQuery.length < 2
                        ? Services.Translation.tr("Type at least 2 characters to search...")
                        : root.filteredResults.length === 0
                            ? Services.Translation.tr("No results found for '%1'").arg(root.searchQuery)
                            : Services.Translation.tr("Found %1 result(s) for '%2'", "", root.filteredResults.length).arg(root.filteredResults.length).arg(root.searchQuery)
                    font.pixelSize: Common.Appearance.font.pixelSize.large
                    font.weight: Font.Medium
                    color: Common.Appearance.m3colors.m3onSurface
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Common.Appearance.m3colors.m3outlineVariant
                }
            }

            // Results list
            Repeater {
                model: root.filteredResults

                delegate: RippleButton {
                    required property var modelData
                    required property int index

                    Layout.fillWidth: true
                    implicitHeight: 72
                    buttonRadius: Common.Appearance.rounding.medium
                    colBackground: Common.Appearance.m3colors.m3surfaceContainerLow
                    colBackgroundHover: Common.Appearance.m3colors.m3surfaceContainerHighest

                    onClicked: {
                        root.resultClicked(modelData.pageIndex)
                    }

                    contentItem: RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16

                        // Page icon
                        MaterialSymbol {
                            text: {
                                if (!modelData || modelData.pageIndex === undefined) return "search"
                                if (!root.pages || root.pages.length === 0) return "search"
                                const page = root.pages[modelData.pageIndex]
                                return page?.icon || "search"
                            }
                            iconSize: 24
                            color: Common.Appearance.m3colors.m3primary
                        }

                        // Content
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData?.itemText || ""
                                font.pixelSize: Common.Appearance.font.pixelSize.medium
                                font.weight: Font.Medium
                                color: Common.Appearance.m3colors.m3onSurface
                                elide: Text.ElideRight
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData?.pageName ? Services.Translation.tr("in %1").arg(modelData.pageName) : ""
                                font.pixelSize: Common.Appearance.font.pixelSize.small
                                color: Common.Appearance.m3colors.m3onSurfaceVariant
                                elide: Text.ElideRight
                            }
                        }

                        // Arrow icon
                        MaterialSymbol {
                            text: "arrow_forward"
                            iconSize: 20
                            color: Common.Appearance.m3colors.m3onSurfaceVariant
                        }
                    }

                    StyledToolTip {
                        text: modelData?.pageName ? Services.Translation.tr("Go to %1 page").arg(modelData.pageName) : ""
                    }
                }
            }

            // Empty state when no search query
            Item {
                visible: root.searchQuery.length === 0
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 300

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 16

                    MaterialSymbol {
                        Layout.alignment: Qt.AlignHCenter
                        text: "search"
                        iconSize: 64
                        color: Common.Appearance.m3colors.m3onSurfaceVariant
                        opacity: 0.5
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: Services.Translation.tr("Start typing to search settings")
                        font.pixelSize: Common.Appearance.font.pixelSize.large
                        color: Common.Appearance.m3colors.m3onSurfaceVariant
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: Services.Translation.tr("Press Ctrl+K to focus search")
                        font.pixelSize: Common.Appearance.font.pixelSize.small
                        color: Common.Appearance.m3colors.m3onSurfaceVariant
                        opacity: 0.7
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
