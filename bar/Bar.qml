import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

PanelWindow {
    id: bar
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: 50
    color: "transparent"
    // variables
    property string bla4: "    "
    property string bla12: "                "
    property string userhost: ""
    property string wifiName: ""
    property string terminess: "Terminess Nerd Font Mono"

    property int cpuUsage: 0
    property int memUsage: 0
    property int diskUsage: 0
    property var volLevel: 0
    property var batLevel: 0
    property string batCharge: "-"

    property var cpu: "CPU: " + cpuUsage + "%"
    property var mem: "Mem: " + memUsage + "%"
    property var disk: "Disk: " + diskUsage + "%"
    property var vol: "Vol: " + volLevel + "%"
    property var bat: "BAT" + batCharge + ": " + batLevel + "%"
    property color col1: "#070a0a"
    property color col2: "#330a0a07"
    property color col3: "#66070b07"
    property color col4: "#363636"
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    property string windowiconSource: ""
    // Proccesses
    // I'll fix or shorten them later when i have time
    // ----------------------------------------------------------------- //
    Process {
        id: appmonProc
        command: ["sh", "-c", "activewindow.sh"]
        stdout: SplitParser {
            onRead: data => {
                if (data) windowiconSource = data.trim()
            }
        }
        Component.onCompleted: running = true
    }
    Process {
        id: batProc
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT*/capacity"]
        stdout: SplitParser {
            onRead: data => {
                if (data) {
                    batLevel = data.trim()
                    if (batLevel === "100") {
                        batCharge == "cock"
                    }
                }
            }
        }
        Component.onCompleted: running = true
    }
    Process {
        id: wifiProc
        command: ["sh", "-c", "iwgetid -r"]
        stdout: SplitParser {
            onRead: data => {
                if (data) wifiName = data.trim()
            }
        }
        Component.onCompleted: running = true
    }
    Process {
        id: userhostProc
        command: ["sh", "-c", "echo $(whoami)@$(cat /etc/hostname)"]
        stdout: SplitParser {
            onRead: data => {
                if (data) userhost = data.trim()
            }
        }
        Component.onCompleted: running = true
    }
    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split(/\s+/)
                var user = parseInt(parts[1]) || 0
                var nice = parseInt(parts[2]) || 0
                var system = parseInt(parts[3]) || 0
                var idle = parseInt(parts[4]) || 0
                var iowait = parseInt(parts[5]) || 0
                var irq = parseInt(parts[6]) || 0
                var softirq = parseInt(parts[7]) || 0

                var total = user + nice + system + idle + iowait + irq + softirq
                var idleTime = idle + iowait

                if (lastCpuTotal > 0) {
                    var totalDiff = total - lastCpuTotal
                    var idleDiff = idleTime - lastCpuIdle
                    if (totalDiff > 0) {
                        cpuUsage = Math.round(100 * (totalDiff - idleDiff) / totalDiff)
                        // cpuUsage = usage.toString().padStart(2, "0") + "%"
                    }
                }
                lastCpuTotal = total
                lastCpuIdle = idleTime
            }
        }
        Component.onCompleted: running = true
    }
    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split(/\s+/)
                var total = parseInt(parts[1]) || 1
                var used = parseInt(parts[2]) || 0
                memUsage = Math.round(100 * used / total)
            }
        }
        Component.onCompleted: running = true
    }
    Process {
        id: diskProc
        command: ["sh", "-c", "df / | tail -1"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split(/\s+/)
                var percentStr = parts[4] || "0%"
                diskUsage = parseInt(percentStr.replace('%', '')) || 0
            }
        }
        Component.onCompleted: running = true
    }
    Process {
        id: volProc
        command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | sed -n 's/.* \\([0-9]\\+\\)%.*/\\1/p'"]
        stdout: SplitParser {
               onRead: data => {
                if (data) volLevel = data.trim()
            }
        }
        Component.onCompleted: running = true
    }
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true
            memProc.running = true
            diskProc.running = true
            volProc.running = true
            batProc.running = true
            appmonProc.running = true
        }
    }
    // Menu
    // Modules
    // Right Panel
    // Upper stuff
    Rectangle {
        id: rec_r
        anchors.right: parent.right
        width: 620
        height: 29
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 1.0; color: "black" }
            GradientStop { position: 0.0; color: col2 }
        }
        Rectangle {
            anchors.right: parent.right
            y: 28
            height: 1
            width: 514
            color: "gray"
        }
        Row {
            spacing: 16
            anchors {
                right: parent.right
                rightMargin: 12
                top: parent.top
                topMargin: 5
            }
            Text {
                id: afuckingclock
                font.family: terminess
                font.pixelSize: 16
                text: Qt.formatDateTime(new Date(), "dddd       -       MMMM, dd        -       HH:mm     ")
                color: "white"
                rightPadding: 8
                Timer {
                    interval: 50000
                    running: true
                    repeat: true
                    onTriggered: afuckingclock.text = Qt.formatDateTime(new Date(), "dddd       -       MMMM, dd        -       HH:mm      ")
                }
            }
            Rectangle {
                width: 1
                height: 16
                color: "gray"
            }
            Text {
                id: menu
                y: -11
                text: "󰍜"
                font.pixelSize: 25
                color: "white"
                MouseArea {
                    onClicked: popupLoader.item.visible = !popupLoader.item.visible
                    anchors.fill: parent
                }
            }
        }
    }
    // Lower stuff
    Rectangle {
        anchors {
            top: rec_r.bottom
            right: parent.right
        }
        height: 21
        width: 550
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: col3 }
            GradientStop { position: 1.0; color: "black" }
        }
        Row {
            spacing: 12
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 25
            }
            Text {
                text: cpu + bla4 + mem + bla4 + disk + bla4 + vol + bla4 + bat
                font.family: terminess
                color: "white"
            }
        }
    }
    // Panel Left
    // Upper
    Rectangle {
        id: rec_l
        height: 29
        width: 450
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "black" }
            GradientStop { position: 1.0; color: col3 }
        }
        Rectangle {
            height: 1
            width: 350
            color: "gray"
            anchors {
                bottom: parent.bottom
                left: parent.left
                leftMargin: 48
            }
        }
        Row {
            id: workspacesLayout
            anchors {
                left: parent.left
                leftMargin: 48
                verticalCenter: parent.verticalCenter
            }
            spacing: 8
            Repeater {
                model: 10
                Rectangle {
                    width: 20
                    height: 20
                    radius: 3
                    color: "transparent"
                    border.width: 1
                    border.color: col4
                }
            }
            Rectangle {
                y: 2
                height: 14
                width: 1
                color: "gray"
            }
        }
        Row {
            id: workspaces
            anchors {
                left: parent.left
                leftMargin: 48
                verticalCenter: parent.verticalCenter
            }
            spacing: 8
            Repeater {
                model: Hyprland.workspaces
                Rectangle {
                    width: 20
                    height: 20
                    radius: 3
                    color: modelData.active ? "#4a9eff" : "transparent"
                    border.width: 2
                    border.color: "gray"
                    Text {
                        text: modelData.id
                        anchors.centerIn: parent
                        font.pixelSize: 12
                        font.family: terminess
                        color: "white"
                    }
                }
            }
        }
    }
    // Lower
    Rectangle {
        anchors {
            top: rec_l.bottom
            left: parent.left
        }
        height: 21
        width: 375
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "black" }
            GradientStop { position: 1.0; color: col3 }
        }
        Row {
            x: 42   
            spacing: 16
            Text {
                text: userhost
                font.family: terminess
                font.pixelSize: 15
                color: "white"
            }
            Rectangle {
                y: 4
                width: 1
                height: 14
                color: "gray"
            }
            Text {
                y: 3
                text: "WiFi: " + wifiName
                font.family: terminess
                font.pixelSize: 11
                color: "white"
            }
        }
    }
    Image {
        id: appMonitor // cute and funny thing that displays current active window's icon:
        y: 4
        source: "./../assets/logo.png"
        sourceSize.width: 40
        sourceSize.height: 40
        anchors {
            left: parent.left
            leftMargin: 4
        }
        Image {
            y: anchors.centerIn - 4
            anchors.centerIn: parent
            sourceSize.width: 16
            sourceSize.height: 16
            source: windowiconSource
            // source: "./../assets/testicles.jpg"
        }
    }
}


