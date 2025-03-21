//
//  NotificationManager.swift
//  Gauntlet Gauge
//
//  Created by Aryan Prodduturi on 3/16/25.
//

import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private let preferences = UserPreference.shared
    private var batteryLevelNotifications: [Bool] = [false, false]
    private let userNotificationCenter = UNUserNotificationCenter.current()

    func requestAuthorization() {
        userNotificationCenter.requestAuthorization(completionHandler: {
            permission, _ in
            if permission {
                // print("Notification permission granted")
            } else {
                // print("Notification permission denied. Go to app settings to enable")
            }
        })
    }

    func pushNotification(bluetoothManager: BluetoothManager) {
        if bluetoothManager.selectedPeripheral == nil || bluetoothManager.batteryLevels == [0, 0] {
            return
        }
        
        bluetoothManager.batteryLevels.enumerated().forEach { index, value in
            let batteryLevel = value
            if batteryLevel < preferences.batteryPreference.batteryLevel
                && !batteryLevelNotifications[index]
            {
                postBatteryNotification(
                    percent: batteryLevel,
                    name:
                        "\(bluetoothManager.selectedPeripheral?.name ?? "Unknown")",
                    side: index)
                batteryLevelNotifications[index] = true
            } else if batteryLevel >= preferences.batteryPreference.batteryLevel
            {
                batteryLevelNotifications[index] = false
            }
        }
    }

    private func postBatteryNotification(
        percent: Int, name: String, side: Int
    ) {
        let content = UNMutableNotificationContent()
        content.title = "Low Battery!"
        content.body =
            "\(name)'s \(side == 0 ? "Left" : "Right") side is curently at \(percent)% battery. Please charge it!"
        content.sound = UNNotificationSound.default

        // Create and add the notification request
        let request = UNNotificationRequest(
            identifier: UUID().uuidString, content: content, trigger: nil)

        userNotificationCenter.add(request) { error in
            if let error = error {
                // print("Error adding notification: \(error.localizedDescription)")
            } else {
                // print("Notification scheduled for \(side == 0 ? "Left" : "Right") side")
            }
        }
    }
}
