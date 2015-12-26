
import QtQuick 1.0
import Qt.labs.gestures 2.0

/**
 * Gestures provide the missing functionality
 * over MouseArea which are used in mobile devices.
 */
Rectangle {
    id: main

    width: 800
    height: 480
    color: "darkgreen"

    function walkObject(obj) {
        for (var name in obj) {
            if (obj.hasOwnProperty(name)) {
                console.log("> " + name + " > " + obj[name]);
            }
        }
    }

    Rectangle {
        id: marker
        color: "pink"
        height: 20
        width: 20
        radius: 10
        opacity: 0

        Behavior on opacity {
            NumberAnimation {
                easing.type: Easing.InOutQuad
                duration: 200
            }
        }
    }

    GestureArea {
        id: gArea

        property real initX: 0
        property real initY: 0

        anchors.fill: parent

        Tap {
            onStarted: {
                console.log("Tap onStarted");
                walkObject(gesture);
                gArea.initX = gesture.position.x;
                gArea.initY = gesture.position.y;
            }
            onCanceled: {
                console.log("Tap onCanceled");
            }
            onFinished: {
                console.log("Tap onFinished");
            }
        }

        Pan {
            onStarted: {
                console.log("Pan onStarted");
                marker.opacity = 1;
            }
            onUpdated: {
                console.log("Pan onUpdated");

                marker.x = gesture.lastOffset.x + gArea.initX;
                marker.y = gesture.lastOffset.y + gArea.initY;
            }
            onFinished: {
                console.log("Pan onFinished");
                marker.opacity = 0;
            }
        }

    }

}
