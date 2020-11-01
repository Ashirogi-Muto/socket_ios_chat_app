//
//  SceneDelegate.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 13/10/20.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let uiWindowScene = (scene as? UIWindowScene) else { return }
        window?.tintColor = Constants.PRIMARY_APP_COLOR
        let userDefault = UserDefaults.standard
        let isUserLogedIn = userDefault.bool(forKey: Constants.USER_LOGGED_IN_DEFAULT_KEY)
        if !isUserLogedIn {
            // Create the root view controller as needed
            let viewController = intializeRootViewController(viewType: "login")
            let navigationController = initlializeUINavigationController(viewController: viewController)
            
            // Create the window. Be sure to use this initializer and not the frame one.
            let uiWindow = UIWindow(windowScene: uiWindowScene)
            uiWindow.rootViewController = navigationController
            uiWindow.makeKeyAndVisible()
            window = uiWindow
        }
        else {
            let viewController = intializeRootViewController(viewType: "home")
            let navigationController = initlializeUINavigationController(viewController: viewController)
            let uiWindow = UIWindow(windowScene: uiWindowScene)
            uiWindow.rootViewController = navigationController
            uiWindow.makeKeyAndVisible()
            window = uiWindow
        }
    }
    
    func intializeRootViewController(viewType: String) -> UIViewController {
        let mainstoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let view: UIViewController
        if viewType == "login" {
            view = mainstoryboard.instantiateViewController(withIdentifier: Constants.LOGIN_VIEW_STORYBOARD_ID) as! ViewController
        }
        else {
            view =  mainstoryboard.instantiateViewController(withIdentifier: Constants.USER_CHAT_ROOM_VIEW_STRORYBOARD_ID) as! UserChatRoomsTableViewController
        }
        return view
    }
    
    func initlializeUINavigationController(viewController: UIViewController) -> UINavigationController {
        let navigationController: UINavigationController
        navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    
}

