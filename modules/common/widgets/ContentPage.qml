import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

StyledFlickable {
    id: root
    property real baseWidth: 500
    property bool forceWidth: false
    property real bottomContentPadding: 60

    default property alias data: contentColumn.data

    clip: true
    contentWidth: width
    contentHeight: contentColumn.implicitHeight + root.bottomContentPadding
    implicitWidth: Math.max(root.baseWidth, contentColumn.implicitWidth)
    boundsBehavior: Flickable.StopAtBounds

    ColumnLayout {
        id: contentColumn
        width: {
            // Make it responsive: use available width if smaller than baseWidth
            const availableWidth = root.width - 30; // Account for margins
            const targetWidth = root.forceWidth ? root.baseWidth : Math.max(root.baseWidth, implicitWidth);
            return Math.min(targetWidth, Math.max(availableWidth, 400));
        }
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 12
            bottomMargin: 12
            leftMargin: 15
            rightMargin: 15
        }
        spacing: 20
    }

}
