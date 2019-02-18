import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let center = UNUserNotificationCenter.current()
        
        if let navController = window?.rootViewController as? UINavigationController {
            if let viewController = navController.viewControllers[0] as? ViewController {
                //if we're here then we found our active view controller
                center.delegate = viewController
            }
        }
        
        //create actions for alert
        let show = UNNotificationAction(identifier: "show", title: "Show group", options: .foreground)
        let destroy = UNNotificationAction(identifier: "destroy", title: "Destroy group", options: [.destructive, .authenticationRequired])
        let rename = UNTextInputNotificationAction(identifier: "rename", title: "Rename group", options: [], textInputButtonTitle: "Rename", textInputPlaceholder: "Type the new name here")
        //wrap actions inside a category
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, rename, destroy], intentIdentifiers: [], options: [.customDismissAction])
        //register the category with the system
        center.setNotificationCategories([category])
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


