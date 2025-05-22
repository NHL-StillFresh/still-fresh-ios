//
//  NotificationHandler.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 22/05/2025.
//

import UserNotifications

func notificationsEnabled() -> Bool {
    return UserDefaults.standard.bool(forKey: "notificationsEnabled")
}

func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
            print("Error requesting notification permission: \(error)")
            completion(false)
            return
        }
        completion(granted)
    }
}

func sendTimeNotification(title: String, body: String, after seconds: TimeInterval) {
    if (!notificationsEnabled()) {
        return
    }
    
    let center = UNUserNotificationCenter.current()
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = UNNotificationSound.default
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)

    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    center.add(request) { error in
        if let error = error {
            print("Error scheduling notification: \(error)")
        }
    }
}

func sendCalendarNotification(title: String, body: String, date: Date) {
    if (!notificationsEnabled()) {
        return
    }
    
    let center = UNUserNotificationCenter.current()
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = UNNotificationSound.default
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date), repeats: false)
    
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    center.add(request) { error in
        if let error = error {
            print("Error scheduling notification: \(error)")
        }
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {

        completionHandler()
    }
}
