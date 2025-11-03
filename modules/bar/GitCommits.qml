import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root
    property bool borderless: Config.options.bar.borderless
    property int daysToShow: 5
    property var commitCounts: []
    property int maxCommits: 0

    implicitWidth: gridLayout.implicitWidth + 8
    implicitHeight: Appearance.sizes.barHeight

    // Process to get git commits
    Process {
        id: gitProcess
        running: true
        command: ["bash", "-c", getGitCommand()]

        function getGitCommand() {
            let cmd = "cd ~/.config/quickshell/ii && ";
            for (let i = 0; i < root.daysToShow; i++) {
                if (i > 0) cmd += " && ";
                cmd += `git log --since='${i} days ago' --until='${i-1} days ago' --oneline | wc -l`;
            }
            return cmd;
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                parseCommitData();
            }
        }

        onReadyReadStandardOutput: () => {
            const output = gitProcess.readStandardOutput();
            const lines = output.trim().split('\n');
            root.commitCounts = lines.map(line => parseInt(line.trim()) || 0);
            root.maxCommits = Math.max(...root.commitCounts, 1);
        }

        function parseCommitData() {
            // Data is already parsed in onReadyReadStandardOutput
        }
    }

    // Refresh timer
    Timer {
        interval: 300000 // 5 minutes
        running: true
        repeat: true
        onTriggered: gitProcess.running = false; gitProcess.running = true;
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        onClicked: {
            // Open git log or refresh
            gitProcess.running = false;
            gitProcess.running = true;
        }
    }

    GridLayout {
        id: gridLayout
        anchors.centerIn: parent
        columns: root.daysToShow
        columnSpacing: 3
        rowSpacing: 0

        Repeater {
            model: root.daysToShow

            Rectangle {
                id: dayRect
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 18
                implicitHeight: 18
                radius: 3

                property int commits: root.commitCounts[root.daysToShow - 1 - index] || 0
                property real intensity: commits > 0 ? (commits / root.maxCommits) : 0

                color: {
                    if (commits === 0) {
                        return ColorUtils.transparentize(Appearance.colors.colLayer2, 0.7);
                    }
                    const baseColor = Appearance.colors.colSecondaryContainer;
                    const highlightColor = Appearance.colors.colSecondary;
                    return ColorUtils.mix(baseColor, highlightColor, intensity);
                }

                border.width: 1
                border.color: ColorUtils.transparentize(Appearance.colors.colOutline, 0.7)

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }

                // Tooltip showing commit count
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton

                    PopupToolTip {
                        text: {
                            const daysAgo = root.daysToShow - 1 - index;
                            const dayLabel = daysAgo === 0 ? "Today" :
                                           daysAgo === 1 ? "Yesterday" :
                                           `${daysAgo} days ago`;
                            return `${dayLabel}: ${dayRect.commits} commit${dayRect.commits !== 1 ? 's' : ''}`;
                        }
                        extraVisibleCondition: parent.containsMouse
                    }
                }

                // Subtle animation on hover
                scale: parent.containsMouse ? 1.1 : 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }

    // Icon indicator
    MaterialSymbol {
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: 2
        }
        text: "code"
        iconSize: Appearance.font.pixelSize.normal
        color: Appearance.colors.colOnLayer1
        opacity: 0.6
    }
}
