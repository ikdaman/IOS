//
//  UserNotificationService.swift
//  Ikdaman
//
//  Created by Soo on 11/17/25.
//

import UserNotifications

final class UserNotificationService {

    static let shared = UserNotificationService()

    private init() {}

    func scheduleDailyNotification(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "알림"
        content.body = "읽다만 알림시간이에요."
        content.sound = .default

        var date = DateComponents()
        date.hour = hour
        date.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: date,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "daily_alarm",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("❌ Notification Error:", error)
            } else {
                print("📅 Alarm Scheduled: \(hour):\(minute)")
            }
        }
    }

    func cancelDailyNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_alarm"])
        print("🚫 Daily alarm canceled")
    }
}
