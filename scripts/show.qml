/* ============================================================
 * ZeroLinux - Calamares Installer Slideshow
 * ============================================================ */

import QtQuick 2.12
import QtQuick.Controls 2.12
import calamares.slideshow 1.0

Presentation {
    id: presentation

    // مدة كل شريحة بالميلي ثانية
    timer: Timer {
        interval: 6000
        repeat: true
        running: presentation.activatedInCalamares

        onTriggered: {
            presentation.goToNextSlide()
        }
    }

    // ============ الشريحة 1: الترحيب ============
    Slide {
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: "#0f0f1a"

            Image {
                anchors.centerIn: parent
                width: 200
                height: 200
                source: "logo.png"
                fillMode: Image.PreserveAspectFit
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 80
                text: "مرحباً بك في ZeroLinux"
                color: "#ffffff"
                font.pixelSize: 32
                font.bold: true
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 45
                text: "توزيعة لينكس مخصصة للمحترفين والمطورين"
                color: "#9090aa"
                font.pixelSize: 16
            }
        }
    }

    // ============ الشريحة 2: بيئة KDE ============
    Slide {
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: "#0f0f1a"

            Column {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "🖥️"
                    font.pixelSize: 64
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "بيئة KDE Plasma الكاملة"
                    color: "#4361ee"
                    font.pixelSize: 28
                    font.bold: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "سطح مكتب احترافي وعصري بكامل مميزاته"
                    color: "#aaaacc"
                    font.pixelSize: 16
                }
            }
        }
    }

    // ============ الشريحة 3: أدوات الأمن ============
    Slide {
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: "#0f0f1a"

            Column {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "🔐"
                    font.pixelSize: 64
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "أدوات الأمن المعلوماتي"
                    color: "#4361ee"
                    font.pixelSize: 28
                    font.bold: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "مجموعة متكاملة من أدوات الاختراق الأخلاقي"
                    color: "#aaaacc"
                    font.pixelSize: 16
                }
            }
        }
    }

    // ============ الشريحة 4: أدوات التطوير ============
    Slide {
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: "#0f0f1a"

            Column {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "⚡"
                    font.pixelSize: 64
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "بيئة تطوير متكاملة"
                    color: "#4361ee"
                    font.pixelSize: 28
                    font.bold: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Python، Rust، Go، Node.js والمزيد"
                    color: "#aaaacc"
                    font.pixelSize: 16
                }
            }
        }
    }

    // ============ الشريحة 5: الانتهاء ============
    Slide {
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: "#0f0f1a"

            Column {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "✅"
                    font.pixelSize: 64
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "يتم الآن تثبيت ZeroLinux"
                    color: "#4361ee"
                    font.pixelSize: 28
                    font.bold: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "سيكون نظامك جاهزاً خلال دقائق"
                    color: "#aaaacc"
                    font.pixelSize: 16
                }
            }
        }
    }
}
