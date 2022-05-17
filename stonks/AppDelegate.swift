//
//  AppDelegate.swift
//  stonks
//
//  Created by Samuel Hobel on 9/25/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import AuthenticationServices
import FCAlertView
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NetworkDelegate {

    var window: UIWindow?
    var lastErrorAlertTimestamp = 0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if #available(iOS 13.0, *) {
            window!.overrideUserInterfaceStyle = .dark
        }
        
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        
//        do {
//            try KeychainItem(service: Bundle.main.bundleIdentifier!, account: "userIdentifier").deleteItem()
//        } catch {
//            print("Unable to delete userIdentifier to keychain.")
//        }
        
        NetworkManager.getMyRestApi().networkDelegate = self
        
        if !KeychainItem.currentUserIdentifier.isEmpty {
            DispatchQueue.main.async {
                self.window?.rootViewController?.showHomeViewController()
            }
        }
        
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        appleIDProvider.getCredentialState(forUserID: KeychainItem.currentUserIdentifier) { (credentialState, error) in
//            switch credentialState {
//            case .authorized:
//                DispatchQueue.main.async {
//                    self.window?.rootViewController?.showHomeViewController()
//                }
//            case .revoked, .notFound:
//                break
//            default:
//                break
//            }
//        }
        return true        
    }
    
    func networkError() {
        let now = NSDate().timeIntervalSince1970
        if Int(now) - self.lastErrorAlertTimestamp < 60000 {
            return
        }
        DispatchQueue.main.async {
            if var topController = self.window?.rootViewController?.presentedViewController {
                self.lastErrorAlertTimestamp = Int(now)
                let message = String("Could not contact server")
                let alert = FCAlertView()
                alert.alertBackgroundColor = Constants.themePurple
                alert.titleColor = .white
                alert.subTitleColor = .white
                alert.colorScheme = Constants.darkPink
                alert.doneButtonTitleColor = .white
                alert.secondButtonTitleColor = .darkGray
                alert.firstButtonTitleColor = .darkGray
                alert.dismissOnOutsideTouch = true
                alert.detachButtons = true
                print()
                print()
                print("showing alert in " + (topController.title ?? "a controller with no title"))
                print()
                print()
                alert.showAlert(inView: topController,
                                withTitle: "Error",
                                withSubtitle: message,
                                withCustomImage: UIImage(systemName: "exclamationmark.triangle.fill"),
                                withDoneButtonTitle: "Ok", andButtons: nil)
            }
        }
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

