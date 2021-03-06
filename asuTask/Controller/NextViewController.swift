//
//  NextViewController.swift
//  asuTask
//
//  Created by 金澤武士 on 2019/09/28.
//  Copyright © 2019 tk. All rights reserved.


import UIKit
import RealmSwift
import UserNotifications

class NextViewController: UIViewController, UITextFieldDelegate {
    //UserDefaultsの参照
    let userDefaults = UserDefaults.standard
    //入力されたタスクを入れる変数
    var editText = String()
    //タスク通知フラグ
    var taskNotification = false
    //アラートコントローラー
    var alertController: UIAlertController!
    //タスク優先度のデフォルト値設定
    var taskPriority = "設定なし"
    //タスク通知時刻のデフォルト値設定
    let taskTime = "設定なし"
    //タスク通知時刻(DetailView用)のデフォルト値設定
    let taskTimeForDetailView = "設定なし"
    //タスク名のテキストフィールド
    var taskNameString = String()
    @IBOutlet weak var taskNameTextField: UITextField!
    //タスク通知用ID
    var taskId = "no ID"
    //タスク通知日時のDatePicker
    @IBOutlet weak var taskDatePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
        taskNotification = false
        //デリゲート
        taskNameTextField.delegate = self
        taskNameTextField.text = taskNameString
        //Datepicker無効化
        taskDatePicker.isEnabled = false
        //最小日時を現在時刻に設定
        taskDatePicker.minimumDate = Date()
    }

    //タスク通知セグメント設定
    @IBAction func taskSegment(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            //タスク通知のdatepickerを無効化する処理(タスク通知しない)
            taskDatePicker.isEnabled = false
            taskNotification = false
            //タスク通知のdatepickerを有効化する処理(タスク通知する)
        case 1: taskDatePicker.isEnabled = true
            taskNotification = true

        default:
            taskDatePicker.isEnabled = false
            break
        }
    }

    //キャンセルボタン
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    //returnキーが押された時に発動するメソッド
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //入力可能オーバー文字数の切り取り
        textFieldEditingChanged(textField: taskNameTextField)
        //タスク名が入力されていない場合キーボード閉じる
        taskNameTextField.resignFirstResponder()
        //タスク作成画面へ遷移させる
        return true
    }

    //画面タップでキーボード閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    //タスク優先度ボタン
    @IBAction func taskPriority(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
            //タスク優先度設定：無し
        case 0:
            taskPriority = "設定なし"
            //タスク優先度設定：できたらやる
        case 1:
            taskPriority = "できたらやる"
            //タスク優先度設定：絶対やる
        case 2:
            taskPriority = "絶対やる"
        default:
            taskPriority = "設定なし"
            break
        }
    }

    //完了ボタン
    @IBAction func done(_ sender: Any) {
        textFieldEditingChanged(textField: taskNameTextField)
        editText = (taskNameTextField.text?.trimmingCharacters(in: .whitespaces))!
        if editText.isEmpty == true {
            alert(title: "登録できません",
                message: "タスク名を入力してください")
            print("登録名エラーの為処理終了")
        } else {
            //タスク通知する場合⇨登録時刻が未来の日付なら処理を継続
            if taskNotification == true && checkTime() {
                //タスク通知許可/非許可
                CommonFunction.setNotificationGranted()
                //タスク通知PUSH登録
                setNotification(date: taskDatePicker.date)
                //変数taskTimeにDatePickerの時刻を代入
                let taskTime = CommonFunction.format(date: taskDatePicker!.date)
                let taskTimeForDetailView = CommonFunction.formatforDetailView(date: taskDatePicker!.date)
                //ここでRMに接続し、データの保存を行う
                let newTodaysTask = TodaysTask()

                newTodaysTask.name = editText
                newTodaysTask.time = taskTime
                newTodaysTask.timeForDetail = taskTimeForDetailView
                newTodaysTask.priority = taskPriority
                newTodaysTask.id = taskId
                newTodaysTask.date = Date()

                do {
                    let realm = try Realm()
                    try realm.write({ () -> Void in
                        realm.add(newTodaysTask)
                        print("本日のタスク1件保存完了")
                    })
                } catch {
                    print("本日のタスク1件保存失敗")
                }
                dismiss(animated: true, completion: nil)
                //もしタスク通知がfalseなら。Viewコントローラーのtextarrayに仮値をappend
            } else if taskNotification == false {
                //ここでRMに接続し、データの保存を行う
                let newTodaysTask = TodaysTask()
                newTodaysTask.name = editText
                newTodaysTask.time = taskTime
                newTodaysTask.timeForDetail = taskTimeForDetailView
                newTodaysTask.priority = taskPriority
                newTodaysTask.id = taskId
                //DB接続
                do {
                    let realm = try Realm()
                    try realm.write({ () -> Void in
                        realm.add(newTodaysTask)
                        print("本日のタスク1件保存完了")
                        print(newTodaysTask)
                    })
                } catch {
                    print("本日のタスク1件保存失敗")
                }
                dismiss(animated: true, completion: nil)
            }
        }
    }
    //15文字以上の文字を取り除くメソッド
    func textFieldEditingChanged(textField: UITextField) {
        let maxLength: Int = 15
        guard let text = taskNameTextField.text else { return }
        taskNameTextField.text = String(text.prefix(maxLength))
    }

    //時刻チェックを行うメソッド
    func checkTime() -> Bool {
        let formatter = DateFormatter()
        //Datepickerの秒数を切り捨て
        formatter.dateFormat = "yyyy/MM/dd HH:mm:00"
        let pickertimeToString = formatter.string(from: taskDatePicker.date)
        let pickerTimeConvertedDate = formatter.date(from: pickertimeToString)
        //現在日時
        let currentDate = Date()
        //時刻を比較。過去の日付なら処理を終了。過去の日付じゃなければ処理を継続
        if currentDate >= pickerTimeConvertedDate! {
            alert(title: "登録できません",
                message: "未来の日付を指定してください。")
            print("登録日時エラーの為処理終了")
            return false
        } else {
            print("日時チェックOK.処理継続")
            return true
        }
    }

    //アラート表示用メソッド
    func alert(title: String, message: String) {
        alertController = UIAlertController(title: title,
            message: message,
            preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "了解！",
            style: .default,
            handler: nil))
        present(alertController, animated: true)
    }




    func setNotification(date: Date) {
        //コンテントバッジをインクリメント
        contentBadgeInt += 1

        //UDの参照
        let userDefaults = UserDefaults.standard
        //UDにコンテントバッジの設定を保存
        userDefaults.set(contentBadgeInt, forKey: "contentBadge")

        //通知日時の設定
        var trigger: UNNotificationTrigger
        //noticficationtimeにdatepickerで取得した値をset
        let notificationTime = Calendar.current.dateComponents(in: TimeZone.current, from: date)
        //現在時刻の取得
        let now = Date()
        //変数taskedDateに取得日時をDatecomponens型で代入
        let taskDate = DateComponents(calendar: .current, year: notificationTime.year, month: notificationTime.month, day: notificationTime.day, hour: notificationTime.hour, minute: notificationTime.minute).date!
        //変数secondsに現在時刻とタスク通知日時の差分の秒数を代入
        let seconds = taskDate.seconds(from: now)
        //triggerに現在時刻から〇〇秒後のタスク実行時間をset
        trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        //タスク通知内容の設定
        let content = UNMutableNotificationContent()
        content.title = "\(taskNameString)"
        content.body = "タスクのお知らせ"
        content.sound = .default
        //バッジにNSNumber型でcontentBadgeIntを代入
        content.badge = contentBadgeInt as NSNumber
        //ユニークIDの設定
        let identifier = NSUUID().uuidString
        //登録用リクエストの設定
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        //taskIdにユニークIDを代入
        taskId = identifier
        //通知をセット
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)

    }

}
