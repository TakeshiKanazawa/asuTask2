//
//  AppDelegate.swift
//  asuTask
//
//  Created by 金澤武士 on 2019/09/28.
//  Copyright © 2019 tk. All rights reserved.
//

import UIKit
import UserNotifications
import RealmSwift

//content badge用変数(UserDefaultsで保存管理)
var contentBadgeInt = Int()
//タスク完了数を保存するための変数の宣言(Global)
var doneTaskCount = 1
//ユーザクラス作成フラグ
var userFlg = false
//アラートメッセージフラグ
var alertMsg = false
//UserDefaultsの参照
let userDefaults = UserDefaults.standard
//Realm
var todaysTaskItem: Results<TodaysTask>!
var tomorrowsTaskItem: Results<TomorrowsTask>!

extension Date {
    //引数で指定した日付からの秒数を返す
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Storyboard切り分け
        let storyboard: UIStoryboard = self.grabStoryboard()

        if let window = window {
            window.rootViewController = storyboard.instantiateInitialViewController() as UIViewController?
        }
        self.window?.makeKeyAndVisible()

        return true
    }

    func grabStoryboard() -> UIStoryboard {

        var storyboard = UIStoryboard()
        let height = UIScreen.main.bounds.size.height
        print(height)
        //iphone se's height　= 568
        //iPhone 6, iPhone 6S, iPhone 7, iPhone 8
        if height == 667 {
            storyboard = UIStoryboard(name: "Main", bundle: nil)
            //iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus, iPhone 8 Plus
        } else if height == 736 {
            storyboard = UIStoryboard(name: "iPhone8plus", bundle: nil)
            print("iPhone8plus")
            //iPhone X, iPhone XS, iPhone 11 Pro
        } else if height == 812 {
            storyboard = UIStoryboard(name: "iPhoneXS", bundle: nil)
            //iPhone XR, iPhone 11, iPhone XS Max, iPhone 11 Pro Max
        } else if height == 896 {
            storyboard = UIStoryboard(name: "iPhoneXSMAX", bundle: nil)
        }

        return storyboard
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        let dateBG = Date()
        //現在の時刻をUserdefaltsに保存。
        userDefaults.set(dateBG, forKey: "timeEnterBG")
    }

//アプリがアクティブ状態の時、日付が変わった瞬間などに呼ばれる
    func applicationSignificantTimeChange(_ application: UIApplication) {
        //UDから条件判定のフラグを取得
        UserDefaults.standard.bool(forKey: "alertMsg")
        //タスク移動のアラートを表示
        if alertMsg == false {
            moveTaskAlert()
        }

        //タスク移動処理
        let realm = try! Realm()
        // Realmに保存されてるtomorrowsTask型のオブジェクトを全て取得
        let tomorrowsTask = realm.objects(TomorrowsTask.self)

        for task in tomorrowsTask {
            let todaysTask = TodaysTask()

            todaysTask.name = task.name
            todaysTask.time = task.time
            todaysTask.timeForDetail = task.timeForDetail
            todaysTask.priority = task.priority
            todaysTask.id = task.id

            do {
                let realm = try Realm()
                try realm.write({ () -> Void in
                    realm.add(todaysTask)
                    print("明日のタスク→本日のタスク1件移動完了")
                })
            } catch {
                print("明日のタスク→本日のタスク1件移動完了")
            }
        }
        //タスク削除処理
        do {
            let realm = try Realm()
            try realm.write({ () -> Void in
                realm.delete(tomorrowsTask)
                print("明日のタスク全削除完了")
            })
        } catch {
            print("明日のタスク全削除失敗")
        }

    }


    func applicationWillResignActive(_ application: UIApplication) {

    }

//アプリを開きそうなときに呼ばれるメソッド(BgからFgに変わるとき)
    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    // アプリ起動時に日付変更していた場合のタスク移動リマインド確認アラート
    func moveTaskAlert() {

        let alert: UIAlertController = UIAlertController(title: "日付が変わりました", message: "明日のタスクを今日のタスクへ移動します。", preferredStyle: UIAlertController.Style.alert)
        //Actionの設定
        let okAction: UIAlertAction = UIAlertAction(title: "了解！", style: UIAlertAction.Style.default, handler: {
            // ボタンが押された時の処理（クロージャ）
            (action: UIAlertAction!) -> Void in

        })

        let noMessageAction: UIAlertAction = UIAlertAction(title: "今後このメッセージは表示しない", style: UIAlertAction.Style.destructive, handler: {
            // ボタンが押された時の処理（クロージャ）
            (action: UIAlertAction!) -> Void in
            //下記のフラグ設定をUDに保存
            alertMsg = true
            //UserDefaultsの参照
            let userDefaults = UserDefaults.standard
            //残しておきたい設定を保存する
            userDefaults.set(alertMsg, forKey: "alertMsg")
        })

        // ③ UIAlertControllerにActionを追加
        alert.addAction(okAction)
        alert.addAction(noMessageAction)

        // ④ Alertを表示
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    //月日のみを戻り値とするdateformatメソッド
    func dateFormat(date: Date) -> String {
        let f = DateFormatter()
        //日付のみ出力指定
        f.dateStyle = .long
        //時刻は出力しない
        f.timeStyle = .none
        return f.string(from: date)
    }



//アプリを開いたときに呼ばれるメソッド(起動時&BgからFgに変わるとき)
    func applicationDidBecomeActive(_ application: UIApplication) {

        //UDに保存値があれば取り出し
        if let contentBadge = userDefaults.object(forKey: "contentBadge") {
            contentBadgeInt = contentBadge as! Int
        }
        //現在時刻取得
        let now_day = Date()
        // 日時経過チェック
        if userDefaults.object(forKey: "timeEnterBG") != nil {
            let past_day = userDefaults.object(forKey: "timeEnterBG") as! Date
            //日にちが変わっていた場合
            if dateFormat(date: now_day) != dateFormat(date: past_day) {

                //UDから条件判定のフラグを取得
                UserDefaults.standard.bool(forKey: "alertMsg")
                //タスク移動のアラートを表示
                if alertMsg == false {
                    moveTaskAlert()
                }
                //タスク移動処理
                let realm = try! Realm()
                // Realmに保存されてるtomorrowsTask型のオブジェクトを全て取得
                let tomorrowsTask = realm.objects(TomorrowsTask.self)

                for task in tomorrowsTask {
                    let todaysTask = TodaysTask()

                    todaysTask.name = task.name
                    todaysTask.time = task.time
                    todaysTask.timeForDetail = task.timeForDetail
                    todaysTask.priority = task.priority
                    todaysTask.id = task.id

                    do {
                        let realm = try Realm()
                        try realm.write({ () -> Void in
                            realm.add(todaysTask)
                            print("明日のタスク→本日のタスク1件移動完了")
                        })
                    } catch {
                        print("明日のタスク→本日のタスク1件移動完了")
                    }
                }
                //タスク削除処理
                do {
                    let realm = try Realm()
                    try realm.write({ () -> Void in
                        realm.delete(tomorrowsTask)
                        print("明日のタスク全削除完了")
                    })
                } catch {
                    print("明日のタスク全削除失敗")
                }
            }
        }
    }

//フリックしてアプリを終了させた時に呼ばれるメソッド
    func applicationWillTerminate(_ application: UIApplication) {

    }

    // フォアグラウンドの場合でも通知を表示するメソッド
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

}




