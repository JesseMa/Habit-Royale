import Foundation
import UserNotifications
import FirebaseMessaging

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isPermissionGranted = false
    private let notificationCenter = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        notificationCenter.delegate = self
        Messaging.messaging().delegate = self
    }
    
    // MARK: - Permission Management
    
    func requestPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
            
            await MainActor.run {
                self.isPermissionGranted = granted
            }
            
            if granted {
                await registerForRemoteNotifications()
            }
            
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }
    
    private func registerForRemoteNotifications() async {
        await MainActor.run {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func checkPermissionStatus() async {
        let settings = await notificationCenter.notificationSettings()
        
        await MainActor.run {
            self.isPermissionGranted = settings.authorizationStatus == .authorized
        }
    }
    
    // MARK: - Local Notifications
    
    func scheduleHabitReminder(title: String, body: String, hour: Int, minute: Int = 0) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let identifier = "habit-reminder-\(hour)-\(minute)"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling habit reminder: \(error)")
            }
        }
    }
    
    func schedulePetHealthReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Dein Pet braucht dich! 🐾"
        content.body = "Die Gesundheit deines Pets ist niedrig. Erfülle deine Gewohnheiten, um es zu heilen!"
        content.sound = .default
        content.badge = 1
        
        // Trigger after 1 hour if pet health is low
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
        let request = UNNotificationRequest(identifier: "pet-health-low", content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling pet health reminder: \(error)")
            }
        }
    }
    
    func scheduleStreakMilestone(streak: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Streak-Meilenstein erreicht! 🔥"
        content.body = "Du hast eine \(streak)-Tage-Serie erreicht! Weiter so!"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "streak-milestone-\(streak)", content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling streak milestone: \(error)")
            }
        }
    }
    
    func scheduleAchievementNotification(title: String, description: String) {
        let content = UNMutableNotificationContent()
        content.title = "Neuer Erfolg freigeschaltet! 🌟"
        content.body = "\(title): \(description)"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "achievement-\(UUID().uuidString)", content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling achievement notification: \(error)")
            }
        }
    }
    
    // MARK: - Remote Notifications (Battle Challenges)
    
    func handleBattleChallenge(battleId: String, challengerName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Neue Kampf-Herausforderung! ⚔️"
        content.body = "\(challengerName) hat dich zu einem Kampf herausgefordert!"
        content.sound = .default
        content.badge = 1
        content.userInfo = [
            "type": "battle_challenge",
            "battleId": battleId,
            "challengerName": challengerName
        ]
        
        // Add action buttons
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_BATTLE", title: "Annehmen", options: [])
        let declineAction = UNNotificationAction(identifier: "DECLINE_BATTLE", title: "Ablehnen", options: [])
        let category = UNNotificationCategory(identifier: "BATTLE_CHALLENGE", actions: [acceptAction, declineAction], intentIdentifiers: [], options: [])
        
        notificationCenter.setNotificationCategories([category])
        content.categoryIdentifier = "BATTLE_CHALLENGE"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "battle-\(battleId)", content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling battle challenge: \(error)")
            }
        }
    }
    
    // MARK: - Notification Management
    
    func removeAllPendingNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    func removePendingNotifications(withIdentifiers identifiers: [String]) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
        notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
    
    func getBadgeCount() -> Int {
        return UIApplication.shared.applicationIconBadgeNumber
    }
    
    func setBadgeCount(_ count: Int) {
        UIApplication.shared.applicationIconBadgeNumber = count
    }
    
    func clearBadge() {
        setBadgeCount(0)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        switch response.actionIdentifier {
        case "ACCEPT_BATTLE":
            if let battleId = userInfo["battleId"] as? String {
                handleBattleAcceptance(battleId: battleId)
            }
            
        case "DECLINE_BATTLE":
            if let battleId = userInfo["battleId"] as? String {
                handleBattleDecline(battleId: battleId)
            }
            
        case UNNotificationDefaultActionIdentifier:
            // Handle tap on notification
            handleNotificationTap(userInfo: userInfo)
            
        default:
            break
        }
        
        completionHandler()
    }
    
    private func handleBattleAcceptance(battleId: String) {
        // Navigate to battle and accept it
        NotificationCenter.default.post(name: .init(Constants.NotificationNames.newBattleChallenge), object: ["battleId": battleId, "action": "accept"])
    }
    
    private func handleBattleDecline(battleId: String) {
        // Decline the battle
        Task {
            // Call Firebase function to decline battle
        }
    }
    
    private func handleNotificationTap(userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String else { return }
        
        switch type {
        case "battle_challenge":
            if let battleId = userInfo["battleId"] as? String {
                NotificationCenter.default.post(name: .init(Constants.NotificationNames.newBattleChallenge), object: ["battleId": battleId])
            }
            
        case "habit_reminder":
            NotificationCenter.default.post(name: .init(Constants.NotificationNames.habitReminder), object: nil)
            
        case "pet_health_low":
            NotificationCenter.default.post(name: .init(Constants.NotificationNames.petHealthLow), object: nil)
            
        default:
            break
        }
    }
}

// MARK: - MessagingDelegate

extension NotificationManager: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        
        // Save FCM token to Firestore for the current user
        Task {
            await saveFCMToken(token)
        }
    }
    
    private func saveFCMToken(_ token: String) async {
        guard let userId = AuthenticationManager.shared.currentUser?.id else { return }
        
        do {
            try await Firestore.firestore()
                .collection("users").document(userId)
                .updateData(["fcmToken": token])
        } catch {
            print("Error saving FCM token: \(error)")
        }
    }
}