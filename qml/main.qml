import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12
import org.cyber.launcher 1.0
import MeuiKit 1.0 as Meui

Item {
    id: root

    property var desktopAvailableHeight: Screen.desktopAvailableHeight
    property var desktopAvailableWidth: Screen.desktopAvailableWidth

    Wallpaper {
        id: backend
    }

    Image {
        id: wallpaper
        anchors.fill: parent
        source: "file://" + backend.wallpaper
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectCrop
        clip: true
        cache: false
    }

    FastBlur {
        id: wallpaperBlur
        anchors.fill: parent
        source: wallpaper
        radius: 64
    }

    ColorOverlay {
        anchors.fill: parent
        source: wallpaperBlur
        color: "#000000"
        opacity: 0.6
        visible: true
    }

    LauncherModel {
        id: launcherModel
    }

    Connections {
        target: launcherModel

        function onApplicationLaunched() {
            hideLauncher()
        }
    }

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.topMargin: root.height === root.desktopAvailableHeight ? Meui.Units.largeSpacing * 2
                                                                       : (root.height - root.desktopAvailableHeight) / 2
        anchors.bottomMargin: root.height === root.desktopAvailableHeight ? Meui.Units.largeSpacing * 2
                                                                          : root.height - root.desktopAvailableHeight + Meui.Units.largeSpacing * 2
        anchors.leftMargin: root.width === root.desktopAvailableWidth ? Meui.Units.largeSpacing * 2
                                                                      : (root.width - root.desktopAvailableWidth) * 2
        anchors.rightMargin: root.width === root.desktopAvailableWidth ? Meui.Units.largeSpacing * 2
                                                                       : root.width - root.desktopAvailableWidth

        spacing: Meui.Units.largeSpacing * 2

        Item {
            id: searchItem
            Layout.fillWidth: true
            height: 40

            TextField {
                id: textField
                anchors.centerIn: parent
                width: searchItem.width * 0.2
                height: parent.height

                placeholderText: qsTr("Search")
                focus: Qt.StrongFocus

                background: Rectangle {
                    opacity: 0.6
                    radius: textField.height * 0.2
                    color: Meui.Theme.backgroundColor
                    border.width: 1
                    border.color: Qt.rgba(255, 255, 255, 0.1)
                }

                onTextChanged: {
                    launcherModel.search(text)
                }

                Keys.onEscapePressed: hideLauncher()
            }
        }

        Item {
            id: gridItem
            Layout.fillHeight: true
            Layout.fillWidth: true

            LauncherGridView {
                id: grid
                anchors.fill: parent
                anchors.leftMargin: gridItem.width * 0.02
                anchors.rightMargin: gridItem.width * 0.02
                Layout.alignment: Qt.AlignHCenter

                Label {
                    anchors.centerIn: parent
                    text: qsTr("Not found")
                    font.pointSize: 30
                    color: "white"
                    visible: grid.count === 0
                }
            }
        }

        PageIndicator {
            id: pageIndicator
            count: grid.pages
            currentIndex: grid.currentPage
            onCurrentIndexChanged: grid.currentPage = currentIndex
            interactive: true
            spacing: Meui.Units.largeSpacing
            Layout.alignment: Qt.AlignHCenter

            delegate: Rectangle {
                width: 10
                height: width
                radius: width / 2
                color: index === pageIndicator.currentIndex ? "white" : Qt.darker("white")
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1

        onClicked: {
            hideLauncher()
        }
    }

    function showLauncher() {
        launcher.show()
    }

    function hideLauncher() {
        textField.text = ""
        launcher.hide()
    }
}
