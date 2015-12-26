// main.qml

import QtQuick 2.0
import QtQuick.Window 2.0
import TimeManager 3.14

Window {
    width: 600
    height: 400
    color: "black"
    title: "For Example 5"

    TimezoneInfo {
        id: tInfo
    }

    Text {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        width: parent.width
        height: 50
        text: tInfo.timezone
        font.pixelSize: 20
        color: "white"
    }

    Flickable {
        anchors.fill: parent
        anchors.topMargin: 50
        contentHeight: contentItem.childrenRect.height
        clip: true
        Column {
            spacing: 2
            Repeater {
                // Once this element has been created, load timezones
                Component.onCompleted: model = tInfo.getTimezones()

                Rectangle {
                    width: Screen.width
                    height: 50

                    // Background color differs for even and odd items
                    color: index % 2 == 0 ? "#11262B" : "#383734"
                    Text {
                        anchors.fill: parent
                        anchors.margins: 10
                        text: modelData
                        font.pixelSize: 20
                        color: "white"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            tInfo.timezone = modelData
                        }
                    }
                } // Rectangle
            }
        } // Column
    }
}
