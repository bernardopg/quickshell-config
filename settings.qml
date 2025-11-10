//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

// Adjust this to make the app smaller or larger
//@ pragma Env QT_SCALE_FACTOR=1

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions as CF
import "modules/settings" as Settings

ApplicationWindow {
    id: root
    flags: Qt.Window
    property string firstRunFilePath: CF.FileUtils.trimFileProtocol(`${Directories.state}/user/first_run.txt`)
    property string firstRunFileContent: "This file is just here to confirm you've been greeted :>"
    property real contentPadding: 8
    property bool showNextTime: false

    // Function to minimize window
    function minimizeWindow() {
        // On Wayland/Qt, showMinimized() doesn't work reliably for ApplicationWindow
        // Use hide() which makes the window invisible but keeps it in memory
        // Window can be shown again via Hyprland's window list or by reopening settings
        root.hide()
    }

    property var pages: [
        {
            name: Translation.tr("Quick"),
            icon: "instant_mix",
            component: "modules/settings/QuickConfig.qml"
        },
        {
            name: Translation.tr("General"),
            icon: "browse",
            component: "modules/settings/GeneralConfig.qml"
        },
        {
            name: Translation.tr("Bar"),
            icon: "toast",
            iconRotation: 180,
            component: "modules/settings/BarConfig.qml"
        },
        {
            name: Translation.tr("Background"),
            icon: "texture",
            component: "modules/settings/BackgroundConfig.qml"
        },
        {
            name: Translation.tr("Interface"),
            icon: "bottom_app_bar",
            component: "modules/settings/InterfaceConfig.qml"
        },
        {
            name: Translation.tr("Services"),
            icon: "settings",
            component: "modules/settings/ServicesConfig.qml"
        },
        {
            name: Translation.tr("Advanced"),
            icon: "construction",
            component: "modules/settings/AdvancedConfig.qml"
        },
        {
            name: Translation.tr("About"),
            icon: "info",
            component: "modules/settings/About.qml"
        }
    ]
    property int currentPage: 0
    property string searchQuery: ""
    property bool searchFocused: false

    visible: true
    onClosing: Qt.quit()
    title: "illogical-impulse Settings"

    Component.onCompleted: {
        MaterialThemeLoader.reapplyTheme()
        Config.readWriteDelay = 0 // Settings app always only sets one var at a time so delay isn't needed
    }

    minimumWidth: 600
    minimumHeight: 400
    width: Math.min(950, Screen.width * 0.8)
    height: Math.min(650, Screen.height * 0.8)
    color: Appearance.m3colors.m3background

    ColumnLayout {
        anchors {
            fill: parent
            margins: contentPadding
        }

        Keys.onPressed: (event) => {
            if (event.modifiers === Qt.ControlModifier) {
                if (event.key === Qt.Key_K) {
                    searchField.forceActiveFocus()
                    event.accepted = true;
                }
                else if (event.key === Qt.Key_PageDown) {
                    root.currentPage = Math.min(root.currentPage + 1, root.pages.length - 1)
                    event.accepted = true;
                }
                else if (event.key === Qt.Key_PageUp) {
                    root.currentPage = Math.max(root.currentPage - 1, 0)
                    event.accepted = true;
                }
                else if (event.key === Qt.Key_Tab) {
                    root.currentPage = (root.currentPage + 1) % root.pages.length;
                    event.accepted = true;
                }
                else if (event.key === Qt.Key_Backtab) {
                    root.currentPage = (root.currentPage - 1 + root.pages.length) % root.pages.length;
                    event.accepted = true;
                }
            }
        }

        Item { // Titlebar
            visible: Config.options?.windows.showTitlebar
            Layout.fillWidth: true
            Layout.fillHeight: false
            implicitHeight: Math.max(titleText.implicitHeight, windowControlsRow.implicitHeight)

            // Enable window dragging by clicking on titlebar
            DragHandler {
                target: null
                onActiveChanged: {
                    if (active) {
                        root.startSystemMove()
                    }
                }
            }

            // Double-click to maximize/restore
            TapHandler {
                acceptedButtons: Qt.LeftButton
                onDoubleTapped: {
                    if (root.visibility === Window.Maximized) {
                        root.showNormal()
                    } else {
                        root.showMaximized()
                    }
                }
            }

            StyledText {
                id: titleText
                anchors {
                    left: Config.options.windows.centerTitle ? undefined : parent.left
                    horizontalCenter: Config.options.windows.centerTitle ? parent.horizontalCenter : undefined
                    verticalCenter: parent.verticalCenter
                    leftMargin: 12
                }
                color: Appearance.colors.colOnLayer0
                text: Translation.tr("Settings")
                font {
                    family: Appearance.font.family.title
                    pixelSize: Appearance.font.pixelSize.title
                    variableAxes: Appearance.font.variableAxes.title
                }
            }

            // Search bar
            Rectangle {
                id: searchBar
                anchors {
                    left: titleText.right
                    right: windowControlsRow.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: 24
                    rightMargin: 16
                }
                visible: root.width > 600
                height: 36
                radius: Appearance.rounding.full
                color: CF.ColorUtils.transparentize(Appearance.m3colors.m3surfaceContainerHighest, 0.5)
                border.width: searchField.activeFocus ? 2 : 0
                border.color: Appearance.m3colors.m3primary

                Behavior on border.width {
                    NumberAnimation {
                        duration: 150
                        easing.type: Appearance.animation.elementMove.type
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 8
                    spacing: 8

                    MaterialSymbol {
                        text: "search"
                        iconSize: 20
                        color: searchField.activeFocus ? Appearance.m3colors.m3primary : Appearance.m3colors.m3onSurfaceVariant
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        placeholderText: Translation.tr("Search settings...") + " (Ctrl+K)"
                        placeholderTextColor: Appearance.m3colors.m3onSurfaceVariant
                        color: Appearance.m3colors.m3onSurface
                        font {
                            family: Appearance.font.family.main
                            pixelSize: Appearance.font.pixelSize.medium
                        }
                        background: Item {}
                        verticalAlignment: TextInput.AlignVCenter
                        selectByMouse: true

                        onTextChanged: {
                            root.searchQuery = text.toLowerCase()
                        }

                        onActiveFocusChanged: {
                            root.searchFocused = activeFocus
                        }

                        Keys.onEscapePressed: {
                            text = ""
                            focus = false
                        }
                    }

                    RippleButton {
                        visible: searchField.text.length > 0
                        buttonRadius: Appearance.rounding.full
                        implicitWidth: 24
                        implicitHeight: 24
                        colBackground: "transparent"
                        colBackgroundHover: CF.ColorUtils.transparentize(Appearance.m3colors.m3onSurface, 0.08)
                        onClicked: {
                            searchField.text = ""
                        }
                        contentItem: MaterialSymbol {
                            anchors.centerIn: parent
                            text: "close"
                            iconSize: 18
                            color: Appearance.m3colors.m3onSurfaceVariant
                        }
                        StyledToolTip {
                            text: Translation.tr("Clear search")
                        }
                    }
                }
            }

            RowLayout { // Window controls row
                id: windowControlsRow
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                spacing: 4

                RippleButton {
                    buttonRadius: Appearance.rounding.full
                    implicitWidth: 35
                    implicitHeight: 35
                    onClicked: () => {
                        root.minimizeWindow()
                    }
                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        text: "minimize"
                        iconSize: 20
                    }
                    StyledToolTip {
                        text: Translation.tr("Minimize")
                    }
                }

                RippleButton {
                    buttonRadius: Appearance.rounding.full
                    implicitWidth: 35
                    implicitHeight: 35
                    onClicked: () => {
                        if (root.visibility === Window.Maximized) {
                            root.showNormal()
                        } else {
                            root.showMaximized()
                        }
                    }
                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        text: root.visibility === Window.Maximized ? "fullscreen_exit" : "fullscreen"
                        iconSize: 20
                    }
                    StyledToolTip {
                        text: root.visibility === Window.Maximized ? Translation.tr("Restore") : Translation.tr("Maximize")
                    }
                }

                RippleButton {
                    buttonRadius: Appearance.rounding.full
                    implicitWidth: 35
                    implicitHeight: 35
                    onClicked: root.close()
                    colBackground: CF.ColorUtils.transparentize(Appearance.colors.colLayer1Hover, 1)
                    colBackgroundHover: Qt.rgba(0.8, 0.2, 0.2, 0.15)
                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        text: "close"
                        iconSize: 20
                    }
                    StyledToolTip {
                        text: Translation.tr("Close")
                    }
                }
            }
        }

        RowLayout { // Window content with navigation rail and content pane
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: contentPadding
            Item {
                id: navRailWrapper
                Layout.fillHeight: true
                Layout.margins: 5
                implicitWidth: navRail.expanded ? 115 : fab.baseSize
                Behavior on implicitWidth {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
                NavigationRail { // Window content with navigation rail and content pane
                    id: navRail
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    spacing: 4
                    expanded: root.width > 750

                    NavigationRailExpandButton {
                        focus: root.visible
                    }

                    FloatingActionButton {
                        id: fab
                        property bool justCopied: false
                        iconText: justCopied ? "check" : "edit"
                        buttonText: justCopied ? Translation.tr("Path copied") : Translation.tr("Config file")
                        expanded: navRail.expanded
                        maxWidth: navRail.expanded ? 115 : 0
                        downAction: () => {
                            Qt.openUrlExternally(`${Directories.config}/illogical-impulse/config.json`);
                        }
                        altAction: () => {
                            Quickshell.clipboardText = CF.FileUtils.trimFileProtocol(`${Directories.config}/illogical-impulse/config.json`);
                            fab.justCopied = true;
                            revertTextTimer.restart()
                        }

                        Timer {
                            id: revertTextTimer
                            interval: 1500
                            onTriggered: {
                                fab.justCopied = false;
                            }
                        }

                        StyledToolTip {
                            text: Translation.tr("Open the shell config file\nAlternatively right-click to copy path")
                        }
                    }

                    NavigationRailTabArray {
                        currentIndex: root.currentPage
                        expanded: navRail.expanded
                        Repeater {
                            model: root.pages
                            NavigationRailButton {
                                required property var index
                                required property var modelData
                                toggled: root.currentPage === index
                                onPressed: root.currentPage = index;
                                expanded: navRail.expanded
                                buttonIcon: modelData.icon
                                buttonIconRotation: modelData.iconRotation || 0
                                buttonText: modelData.name
                                showToggledHighlight: false
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
            Rectangle { // Content container
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Appearance.m3colors.m3surfaceContainerLow
                radius: Appearance.rounding.windowRounding - root.contentPadding
                clip: true

                Loader {
                    id: pageLoader
                    anchors.fill: parent
                    anchors.margins: 5
                    opacity: 1.0

                    active: Config.ready

                    Component.onCompleted: {
                        source = root.pages[0].component
                    }

                    // Search results component
                    Component {
                        id: searchResultsComponent
                        Settings.SearchResults {
                            searchQuery: root.searchQuery
                            pages: root.pages
                            onResultClicked: (pageIndex) => {
                                root.currentPage = pageIndex
                                searchField.text = ""
                                searchField.focus = false
                            }
                        }
                    }

                    Connections {
                        target: root
                        function onCurrentPageChanged() {
                            // Only switch pages when not searching
                            if (root.searchQuery.length < 2) {
                                switchAnim.complete();
                                switchAnim.start();
                            }
                        }
                        function onSearchQueryChanged() {
                            if (root.searchQuery.length >= 2) {
                                // Show search results
                                pageLoader.sourceComponent = searchResultsComponent
                            } else {
                                // Return to current page
                                pageLoader.sourceComponent = null
                                pageLoader.source = root.pages[root.currentPage].component
                            }
                        }
                    }

                    SequentialAnimation {
                        id: switchAnim

                        NumberAnimation {
                            target: pageLoader
                            properties: "opacity"
                            from: 1
                            to: 0
                            duration: 100
                            easing.type: Appearance.animation.elementMoveExit.type
                            easing.bezierCurve: Appearance.animationCurves.emphasizedFirstHalf
                        }
                        ParallelAnimation {
                            PropertyAction {
                                target: pageLoader
                                property: "source"
                                value: root.pages[root.currentPage].component
                            }
                            PropertyAction {
                                target: pageLoader
                                property: "anchors.topMargin"
                                value: 20
                            }
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: pageLoader
                                properties: "opacity"
                                from: 0
                                to: 1
                                duration: 200
                                easing.type: Appearance.animation.elementMoveEnter.type
                                easing.bezierCurve: Appearance.animationCurves.emphasizedLastHalf
                            }
                            NumberAnimation {
                                target: pageLoader
                                properties: "anchors.topMargin"
                                to: 0
                                duration: 200
                                easing.type: Appearance.animation.elementMoveEnter.type
                                easing.bezierCurve: Appearance.animationCurves.emphasizedLastHalf
                            }
                        }
                    }
                }
            }
        }
    }
}
