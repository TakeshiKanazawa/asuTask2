//
//  AppDelegate.swift
//  asuTask
//
//  Created by 金澤武士 on 2019/09/28.
//  Copyright © 2019 tk. All rights reserved.
//

import UIKit
import UserNotifications

//content badge用変数(UserDefaultsで保存管理)
var contentBadgeInt = Int()
//タスク完了数を保存するための変数の宣言(Global)
var doneTaskCount = 1
//ユーザクラス作成フラグ
var userFlg = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        return true
    }
    



    func applicationDidEnterBackground(_ application: UIApplication) {

    }




    func applicationWillResignActive(_ application: UIApplication) {

    }

//アプリを開きそうなときに呼ばれるメソッド
    func applicationWillEnterForeground(_ application: UIApplication) {
        //UserDefaultsの参照
        let userDefaults = UserDefaults.standard
        //UDに保存値があれば取り出し
        if let contentBadge = userDefaults.object(forKey: "contentBadge") {
            contentBadgeInt = contentBadge as! Int
        }
        print(contentBadgeInt)
        
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


