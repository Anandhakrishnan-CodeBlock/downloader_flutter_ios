import UserNotifications
import UIKit

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    // This method decides what happens when a notification is delivered in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Force display the banner and play a sound
        completionHandler([.banner, .sound])
    }
}

func initNotificationDelegate() {
    // Create delegate and assign
    let center = UNUserNotificationCenter.current()
    let delegate = NotificationDelegate()
    center.delegate = delegate
    
    // Request permission once
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            print("✅ Notifications permission granted")
        } else {
            print("❌ Permission denied: \(error?.localizedDescription ?? "none")")
        }
    }
}

