import Quickshell
import QtQuick
import "./bar"
ShellRoot {
    id: root

    Loader {
        active: true
        sourceComponent: Bar {}
    }
}
