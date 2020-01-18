//
//  AppDelegate.swift
//  asuTask
//
//  Created by 金澤武士 on 2019/09/28.
//  Copyright © 2019 tk. All rights reserved.
//

import UIKit
import UserNotifications
var textArray = [String]()

@UIApplicationMain
class AppDelegate: UIResponder,UIApplicationDelegate {
    
    var globalVarForNotificationBadge = Int()
    //多分使わないコード
    var viewController: ViewController!
    var textArray = [String]()

    var window: UIWindow?
    var dateTime = Date()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        
        return true
    }
    
<<<<<<< HEAD
    //アプリを閉じたときに呼ばれる
    func applicationDidEnterBackground(_ application: UIApplication) {
              
    }
    
    //アプリを閉じそうなときに呼ばれるメソッド
=======
    
    func applicationDidEnterBackground(_ application: UIApplication) {
                
    }
    
    
    
//    func setDateSystem(date: Date) {
//        dateTime = date
//    }
//
    
    
>>>>>>> 4492bf0ae93e87b6464c75b8c41c64062b858900
    func applicationWillResignActive(_ application: UIApplication) {
        
    }

//アプリを開きそうなときに呼ばれるメソッド
    func applicationWillEnterForeground(_ application: UIApplication) {

    }

//アプリを開いたときに呼ばれるメソッド
    func applicationDidBecomeActive(_ application: UIApplication) {

    }
//フリックしてアプリを終了させた時に呼ばれるメソッド
    func applicationWillTerminate(_ application: UIApplication) {

    }
    
    // フォアグラウンドの場合でも通知を表示するメソッド
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    
}


