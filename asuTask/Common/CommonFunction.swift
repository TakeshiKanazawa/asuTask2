//
//  CommonFunction.swift
//  asuTask
//
//  Created by 金澤武士 on 2020/02/02.
//  Copyright © 2020 tk. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

class CommonFunction: NSObject {

    //String型⇨ Date型へ変換を行うメソッド
    class func dateFromString(string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }
    //Date型　⇨ String型へ変換を行うメソッド①
    class func format(date: Date) -> String {

        let dateformatter = DateFormatter()
        dateformatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMdHm", options: 0, locale: Locale(identifier: "ja_JP"))
        let strDate = dateformatter.string(from: date)
        return strDate
    }

    //Date型　⇨ String型へ変換を行うメソッド②(タスク詳細画面用)
    class func formatforDetailView(date: Date) -> String {

        let dateformatter = DateFormatter()
        dateformatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMMhm", options: 0, locale: Locale(identifier: "ja_JP"))
        let strDate = dateformatter.string(from: date)
        return strDate
    }

    class func setNotificationGranted() {

        if #available(iOS 10.0, *) {
            // iOS 10
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { (granted, error) in
                    if error != nil {
                        return
                    }

                    if granted {
                        print("通知許可")

                        let center = UNUserNotificationCenter.current()
                        center.delegate = self as? UNUserNotificationCenterDelegate

                    } else {
                        print("通知拒否")
                    }
                })

        } else {
            // iOS 9以下
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }


    //タスク完了数からLv判定をするためのメソッド
    class func checkTaskLebel(doneTaskCount: Int) -> (Int, String, Bool) {
        var level: Int
        var status: String
        var levelBool: Bool

        switch doneTaskCount {
            //タスクレベル1(タスク完了件数が8件以下)
        case 1...9:
            level = 1
            status = "モンスターのたまご"
            if doneTaskCount == 2 {
                levelBool = true
            } else {
                levelBool = false
            }
            return(level, status, levelBool)

            //タスクレベル2(タスク完了件数が9件以上26以下)

        case 10...29:
            level = 2
            status = "モンスターの卵(孵化前)"
            if doneTaskCount == 10 {
                levelBool = true
            } else {
                levelBool = false
            }
            return(level, status, levelBool)

            //★タスクレベル3(タスク完了件数が27件以上49以下)
        case 30...59:
            level = 3
            status = "スライムモンスター"
            if doneTaskCount == 30 {
                levelBool = true
            } else {
                levelBool = false
            }
            return(level, status, levelBool)

            //タスクレベル4(タスク完了件数が　50件以上74以下)
        case 60...99:
            level = 4
            status = "ウーパーモンスター"
            if doneTaskCount == 60 {
                levelBool = true
            } else {
                levelBool = false
            }
            return(level, status, levelBool)

            //タスクレベル5(タスク完了件数が　75件以上98以下)
        case 100...149:
            level = 5
            status = "かぼちゃモンスター"
            if doneTaskCount == 100 {
                levelBool = true
            } else {
                levelBool = false
            }
            return(level, status, levelBool)

            //★タスクレベル6(タスク完了件数が　99件以上129以下)
        case 150...204:
            level = 6
            status = "ねこモンスター"
            if doneTaskCount == 150 {
                levelBool = true
            } else {
                levelBool = false
            }
            return(level, status, levelBool)

            //タスクレベル7(タスク完了件数が　130件以上169以下)
        case 205...264:
            level = 7
            status = "ゴーレムモンスター"
            if doneTaskCount == 205 {
                levelBool = true
            } else {
                levelBool = false
            }
            return(level, status, levelBool)

            //タスクレベル8(タスク完了件数が　170件以上249以下)
        case 265...319:
            level = 8
            status = "ケルベロスモンスター"
            if doneTaskCount == 265 {
                levelBool = true
            } else {
                levelBool = false
            }
            return(level, status, levelBool)
            //★タスクレベル9(タスク完了件数が　300件以上)
        case 320...:
            level = 9
            status = "ドラゴンモンスター"
            if doneTaskCount == 320 {
                levelBool = true
            } else {
                levelBool = false
            }
            return(level, status, levelBool)

            //デフォルト
        default:
            level = 1
            status = "モンスターのたまご"
            levelBool = false

        }
        return(level, status, levelBool)
    }
}


