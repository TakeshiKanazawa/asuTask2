//
//  DetailViewController.swift
//  asuTask
//
//  Created by 金澤武士 on 2019/10/01.
//  Copyright © 2019 tk. All rights reserved.
//

import UIKit
import RealmSwift

class DetailViewController: UIViewController {

    //Realm
    var todaysTaskItem: Results<TodaysTask>!
    var tomorrowsTaskItem: Results<TomorrowsTask>!
    var userStatus: Results<User>!
    //indexnumber保存用のインスタンス
    var saveIndexNumber = Int()
    //タスク表示名ボタン
    @IBOutlet weak var taskNameButton: UIButton!
    //タスク予定時刻ボタン
    @IBOutlet weak var taskPlannedTimeButton: UIButton!
    //タスク優先度ボタン
    @IBOutlet weak var taskPriorityButton: UIButton!
    //明日タスクへ移動ボタン
    @IBOutlet weak var moveToTomorrowsTaskButton: UIButton!
    //このタスクを削除ボタン
    @IBOutlet weak var deleteTaskButton: UIButton!
    //タスク完了ボタン
    @IBOutlet weak var doneTaskButton: UIButton!

    func delete () {
        //該当セルのRealmデータオブジェクトの作成
        let object: TodaysTask = todaysTaskItem[saveIndexNumber]
        //タスク通知のあるタスクかcheck
        if object.time != "設定なし" { //登録時刻が現在時刻よりも後の場合はタスク削除時にバッジもデクリメントする。
            //まず登録時刻をDate型に変換
            let convertDate = CommonFunction.dateFromString(string: object.time, format: "yyyy/MM/dd HH:mm")
            //現在時刻のインスタンス化
            let now: Date = Date()
            //登録時刻が現在時刻と過去である、もしくは同時刻であった場合
            if convertDate <= now {
                //バッジをデクリメント
                UIApplication.shared.applicationIconBadgeNumber -= 1
                contentBadgeInt = UIApplication.shared.applicationIconBadgeNumber
                //UDの参照
                let userDefaults = UserDefaults.standard
                //UDのバッジの値変更
                userDefaults.set(contentBadgeInt, forKey: "contentBadge")
                //タスク通知ある場合はPUSH通知登録を削除
            } else {
                let center = UNUserNotificationCenter.current()
                center.removePendingNotificationRequests(withIdentifiers: [object.id])
            }
        }

        //Realm接続　データ削除
        do {
            let realm = try Realm()
            try! realm.write {
                //TaskListオブジェクトの削除
                realm.delete(object)
            }
        } catch {
            print("本日のタスクを削除できませんでした")
        }
    }

    //明日タスクへ移動ボタン(Action)
    @IBAction func moveToTomorrowsTaskButton(_ sender: Any) {
        //該当セルのRealmデータオブジェクトの作成
        let object: TodaysTask = self.todaysTaskItem![(saveIndexNumber)]
        //該当のタスクを翌日のタスクへ追加
        let newTomorrowsTask = TomorrowsTask()
        newTomorrowsTask.name = object.name
        newTomorrowsTask.time = object.time
        newTomorrowsTask.timeForDetail = object.timeForDetail
        newTomorrowsTask.priority = object.priority
        newTomorrowsTask.id = object.id

        do {
            let realm = try Realm()
            try realm.write({ () -> Void in
                realm.add(newTomorrowsTask)
                print(newTomorrowsTask)
                print("明日のタスク1件保存完了")
            })
        } catch {
            print("明日のタスク1件保存失敗")
        }
        //該当のタスクを削除
        delete()
        //前画面へ戻る
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteTaskButton(_ sender: Any) {
        //該当のタスクを削除
        delete()
        //前画面へ戻る
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneTaskButton(_ sender: Any) {
        //データ更新準備　Userインスタンス生成
        var doneTaskCount = self.userStatus.first?.doneTask
        //タスク完了件数カウントアップ
        doneTaskCount! += 1
        //ここでタスク完了数に対するレベルチェックメソッドの発動
        let checkDoneTaskCount = CommonFunction.checkTaskLebel(doneTaskCount: doneTaskCount ?? 1)
        //ここでレベルアップ用の戻り値を入手
        let userLevel = (checkDoneTaskCount.0)
        let userStatus = (checkDoneTaskCount.1)
        let levelBool = (checkDoneTaskCount.2)
        //DB接続
        do {
            let realm = try Realm()
            let user = realm.object(ofType: User.self, forPrimaryKey: "0")

            try realm.write {
                user?.level = userLevel
                user?.status = userStatus
                user?.doneTask = doneTaskCount!
                print("ユーザデータ更新完了")
            }
        } catch {
            print("ユーザデータ更新失敗")
        }
        //タスク完了数が条件と合致すれば画面遷移
        if levelBool {
            delete()
            //レベルアップ画面に遷移
            self.performSegue(withIdentifier: "levelUp", sender: nil)
        }
        //削除メソッドの呼び出し
            else {
                delete()
                dismiss(animated: true, completion: nil)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()


        //TodaysTaskクラスに永続化されているデータを取りだす
        do {
            let realm = try Realm()
            todaysTaskItem = realm.objects(TodaysTask.self)
            if todaysTaskItem.count > 1 {
                     todaysTaskItem = todaysTaskItem.sorted(byKeyPath: "date")
            }

            userStatus = realm.objects(User.self)
        } catch {
            print("RealmからTodaysTaskのデータを読み込めませんでした")
        }
        let object: TodaysTask = todaysTaskItem[saveIndexNumber]

        //タスク名の表示名の設定　ボタンの無効化(現時点ではボタン機能は実装しない)
        taskNameButton.setTitle(object.name, for: .normal)
        taskNameButton.isEnabled = false
        //タスク時刻の表示名の設定　ボタンの無効化(現時点ではボタン機能は実装しない)
        taskPlannedTimeButton.setTitle(object.timeForDetail, for: .normal)
        taskPlannedTimeButton.isEnabled = false
        //タスク優先度の表示名の設定 ボタンの無効化(現時点ではボタン機能は実装しない)
        taskPriorityButton.setTitle(object.priority, for: .normal)
        taskPriorityButton.isEnabled = false
    }


    //戻るボタン
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


}
