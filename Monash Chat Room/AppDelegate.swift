//
//  AppDelegate.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 13/10/20.
//

import UIKit
import CoreData
import GoogleSignIn
import UserNotifications
@main
class AppDelegate: UIResponder, UIApplicationDelegate, SocketConnectionDelegate, UNUserNotificationCenterDelegate {
    let notificationCenter = UNUserNotificationCenter.current()
    let options: UNAuthorizationOptions = [.alert, .sound, .badge]
    var loggedInUserEmail: String?
    var userRoomIds: [String]?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
        notificationCenter.delegate = self
        let socketHelper = SocketHelper()
        socketHelper.delegate = self
        socketHelper.connectToSocket()
        GIDSignIn.sharedInstance().clientID = "614194330751-j845em5duqf98sekljsc48vtjoioqrln.apps.googleusercontent.com"
        let userDefault = UserDefaults.standard
        loggedInUserEmail = userDefault.string(forKey: Constants.LOGGED_IN_USER_EMAIL_KEY)
        userRoomIds = userDefault.stringArray(forKey: Constants.USER_ROOMS_IDS_KEY)
        return true
    }
    //MARK: Google Sign In
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions.init(arrayLiteral: [.banner, .badge, .sound, .list]))
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        let chatRoomId = response.notification.request.content.categoryIdentifier
        completionHandler()
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    //MARK INCOMING MESSAGE NOTIFICATIONS
    
    func connectedToSocket(isConnected: Bool) {
        initializeListenerForNotifications()
    }
    
    func initializeListenerForNotifications() {
        SocketHelper.Events.receiveNewMessage.listen { [self] (data) in
            do {
                if let arr = data as? [[String: Any]] {
                    let messageDataJson = try JSONSerialization.data(withJSONObject: arr[0])
                    let message = try JSONDecoder().decode(MessageDetails.self, from: messageDataJson)
                    if message.senderId != loggedInUserEmail && ((userRoomIds?.contains(message.chatRoomId)) != nil) {
                        self.sendNotification(chatRoomId: message.chatRoomId)
                    }
                }

            } catch let error {
                print("ERROR IN <><><>< \(error.localizedDescription)")
            }
        }
    }
    
    func sendNotification(chatRoomId: String) {
        let content = UNMutableNotificationContent()
        content.title = "Hello"
        content.body = "You've got a new message!"
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = chatRoomId
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
        
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Monash_Chat_Room")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

