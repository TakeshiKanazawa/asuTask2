//
//  SettingViewController.swift
//  asuTask
//
//  Created by 金澤武士 on 2019/10/11.
//  Copyright © 2019 tk. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI
import UserNotifications

var nortificationFlg = false

class SettingViewController: UIViewController, MFMailComposeViewControllerDelegate, UNUserNotificationCenterDelegate {

    //segment
    @IBOutlet weak var segmentControl: UISegmentedControl!
    //datepicker
    @IBOutlet weak var dailyTaskNotificationDatePicker: UIDatePicker!

    override func viewDidLoad() {
      
        //UserDefaultsの参照
        let userDefaults = UserDefaults.standard
        
        //UDに保存値があれば取り出し
        if let settingTime = userDefaults.object(forKey: "settingTime")  {
            dailyTaskNotificationDatePicker.date = settingTime as! Date
          }
        
        if let pickerImage = userDefaults.object(forKey: "pickerImage")  {
            dailyTaskNotificationDatePicker.isEnabled = pickerImage as! Bool
            }

        if let settingSegment = userDefaults.object(forKey: "settingSegment")  {
            segmentControl.selectedSegmentIndex = settingSegment as! Int
            }

        super.viewDidLoad()
    }

    //タスク作成お忘れ防止通知セグメント
    @IBAction func dailyTaskNotificationSegment(_ sender: Any) {

        switch (sender as AnyObject).selectedSegmentIndex {
        case 0: //Daily通知しない
            //タスク通知のdatepickerを無効化
            dailyTaskNotificationDatePicker.isEnabled = false
            segmentControl.selectedSegmentIndex = 0
            nortificationFlg = false
            
        case 1: //Daily通知する
            //タスク通知のdatepickerを有効化
            dailyTaskNotificationDatePicker.isEnabled = true
            segmentControl.selectedSegmentIndex = 1
            nortificationFlg = true
        default:
            segmentControl.selectedSegmentIndex = 0
            nortificationFlg = false
            break
        }
    }

    //セッティング画面終了ボタン
     @IBAction func doneSetting(_ sender: Any) {
         //UserDefaultsの参照
         let userDefaults = UserDefaults.standard
         //残しておきたい設定を保存する
         userDefaults.set(segmentControl.selectedSegmentIndex, forKey: "settingSegment")
         userDefaults.set(dailyTaskNotificationDatePicker.date, forKey: "settingTime")
         userDefaults.set(dailyTaskNotificationDatePicker.isEnabled, forKey: "pickerImage")

         //タスク通知があれば登録
         if nortificationFlg
         {
         setDairyTaskNotification()
         } else {
            //登録済みのdaily通知を削除
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: ["dailyNotification"])
        }
         dismiss(animated: true, completion: nil)

     }

    //お問い合わせメーラー起動ボタン
    @IBAction func contact(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["oseans@hotmail.co.jp"]) //宛先アドレス
            mail.setSubject("アプリに関するお問い合わせ") //件名
            mail.setMessageBody("お問い合わせ内容の入力をお願いします。", isHTML: false) //本文
            present(mail, animated: true, completion: nil)
        } else {
            print("送信できません")
        }
    }

    // アプリのレビュー画面へ遷移ボタン
    @IBAction func review(_ sender: Any) {

        // TODO: app idが現在未登録のため仮番号。発行次第正しいものへ変更
        let MY_APP_ID = "1274048262"
        //レビュータブを開くためのURLを指定する
        // TODO: app idが現在未登録のため仮番号。発行次第正しいものへ変更
        let urlString =
            "itms-apps://itunes.apple.com/jp/app/id\(1274048262)?mt=8&action=write-review"
        if let url = URL(string: urlString) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

    //通知表示の許諾〜トリガー設定〜通知の表示内容の設定〜登録を行うメソッド

    func setDairyTaskNotification() {
        //タスク通知　許可/非許可
        CommonFunction.setNotificationGranted()

        //通知日時の設定
        var trigger: UNNotificationTrigger
        //noticficationtimeにdatepickerで取得した値をset
        var forSetnotificationTime = DateComponents()

        let notificationTime = Calendar.current.dateComponents(in: TimeZone.current, from: dailyTaskNotificationDatePicker.date)

        var intNotificationHour: Int!
        var intNotificationMinute: Int!

        intNotificationHour = notificationTime.hour
        intNotificationMinute = notificationTime.minute

        forSetnotificationTime.hour = intNotificationHour
        forSetnotificationTime.minute = intNotificationMinute

        //triggerに現在時刻から〇〇秒後のタスク実行時間をset
        trigger = UNCalendarNotificationTrigger(dateMatching: forSetnotificationTime, repeats: false)
        //タスク通知内容の設定
        let content = UNMutableNotificationContent()
        content.title = "明日のタスクを確認しましょう"
        content.body = "明日やることはありませんか？"
        content.sound = .default
        //通知スタイルを指定
        let request = UNNotificationRequest(identifier: "dailyNotification", content: content, trigger: trigger)
        //通知をセット
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("キャンセル")
        case .saved:
            print("下書き保存")
        case .sent:
            print("送信成功")
        default:
            print("送信失敗")
        }
        dismiss(animated: true, completion: nil)
    }
    
}

