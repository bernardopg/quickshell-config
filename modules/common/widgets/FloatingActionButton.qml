import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

/**
 * Material 3 FAB.
 */
RippleButton {
    id: root
    property string iconText: "add"
    property bool expanded: false
    property real baseSize: 44
    property real elementSpacing: 5
    property real maxWidth: 0 // 0 means no limit
    implicitWidth: {
        if (!expanded) return baseSize;
        const calculatedWidth = Math.max(contentRowLayout.implicitWidth + 10 * 2, baseSize);
        return maxWidth > 0 ? Math.min(calculatedWidth, maxWidth) : calculatedWidth;
    }
    implicitHeight: baseSize
    buttonRadius: baseSize / 14 * 4
    colBackground: Appearance.colors.colPrimaryContainer
    colBackgroundHover: Appearance.colors.colPrimaryContainerHover
    colRipple: Appearance.colors.colPrimaryContainerActive
    property color colOnBackground: Appearance.colors.colOnPrimaryContainer
    contentItem: Row {
        id: contentRowLayout
        property real horizontalMargins: (root.baseSize - icon.width) / 2
        anchors {
            verticalCenter: parent?.verticalCenter
            left: parent?.left
            leftMargin: contentRowLayout.horizontalMargins
        }
        spacing: 0

        MaterialSymbol {
            id: icon
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            iconSize: 22
            color: root.colOnBackground
            text: root.iconText
        }
        Loader {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.buttonText?.length > 0
            active: true
            sourceComponent: Revealer {
                visible: root.expanded || implicitWidth > 0
                reveal: root.expanded
                implicitWidth: reveal ? (buttonText.implicitWidth + root.elementSpacing + contentRowLayout.horizontalMargins) : 0
                StyledText {
                    id: buttonText
                    anchors {
                        left: parent.left
                        leftMargin: root.elementSpacing
                    }
                    width: Math.min(implicitWidth, root.maxWidth > 0 ? root.maxWidth - icon.width - root.elementSpacing - contentRowLayout.horizontalMargins * 2 : implicitWidth)
                    text: root.buttonText
                    color: Appearance.colors.colOnPrimaryContainer
                    font.pixelSize: 12
                    font.weight: 450
                    elide: Text.ElideRight
                    clip: true
                }
            }
        }
    }
}
