//
//  ViewController.swift
//  asuTask
//
//  Created by 金澤武士 on 2019/09/28.
//  Copyright © 2019 tk. All rights reserved.
//

import UIKit
import UserNotifications
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UNUserNotificationCenterDelegate, UIGestureRecognizerDelegate {

    //Realm
    var todaysTaskItem: Results<TodaysTask>!
    var userStatus: Results<User>!

    //タスク入力用テキストフィールド
    @IBOutlet weak var textField: UITextField!
    //テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    //タスク件数表示用ラベル
    @IBOutlet weak var todaysTaskMessageLabel: UILabel!
    //ユーザレベル表示用ラベル
    @IBOutlet weak var usersLevelLavel: UILabel!
    //レベルごとのステータスを表示するアイコン
    @IBOutlet weak var usersImageIcon: UIImageView!
    //リターンキーが押されたかどうかを判定する
    @IBOutlet weak var settingButton: UIButton!
    var textFieldTouchReturnKey = false
    //タスク名を入れる配列
    var textArray = [String]()
//    //選択されたセルの番号を入れるための変数
    var indexNumber = Int()
    //入力されたタスクを入れる変数
    var editText = String()


    var refreshControl: UIRefreshControl!
    var isRefresh = false

    //スワイプで更新用
    @objc func refresh()
    {
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    //画面タッチでキーボード閉じる
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            textField.resignFirstResponder()
        }
    }

    @IBAction func settingButton(_ sender: Any) {
        BtnAnimation(sender: settingButton)
    }

    //タスクレベル表示用
    @IBOutlet weak var taskLevelLabel: UILabel!
    //settingButton回転アニメーション用コード
    func BtnAnimation(sender: UIButton) {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(Double.pi / 180) * 270
        rotationAnimation.duration = 0.6
        rotationAnimation.repeatCount = 1
        sender.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //TodaysTaskクラスに永続化されているデータを取りだす
        do {
            let realm = try Realm()
            todaysTaskItem = realm.objects(TodaysTask.self)
            userStatus = realm.objects(User.self)
            //tableView.reloadData()
        } catch { print("RealmからTodaysTaskのデータを読み込めませんでした")
        }
        //もしユーザクラス作成がまだなら
        if userFlg != true {
            do {
                let realm = try Realm()
                let user = User()
                try realm.write({ () -> Void in
                    realm.add(user)
                    userFlg = true
                    print("ユーザクラス作成完了")
                })
            } catch {
                print("ユーザクラス作成失敗もしくは作成済み")
            }
        }

        //ユーザLevel表示
        let status = userStatus?.first?.status
        let level = userStatus?.first!.level

        usersLevelLavel.text = "\(level!)"
        let myImage = UIImage(named: "\(status!)")
        usersImageIcon.image = myImage

        //テーブルビューの枠線
        tableView.separatorColor = .black
        //タップでキーボード閉じる
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(ViewController.tapped(_:)))
        //tableviewへのtapを検知させる
        tapGesture.cancelsTouchesInView = false
        //tabbarのデザイン
        UITabBar.appearance().barTintColor = UIColor.systemGreen
        UITabBar.appearance().tintColor = UIColor.blue
        UITabBar.appearance().unselectedItemTintColor = UIColor.white

        //デリゲート
        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)

        //todaysTaskMessageLabelのデザイン
        let rgba = UIColor(red: 1.0, green: 127 / 255.0, blue: 161 / 255.0, alpha: 1.0)
        todaysTaskMessageLabel.backgroundColor = rgba // 背景色
        todaysTaskMessageLabel.textAlignment = NSTextAlignment.center //文字中央揃え
        todaysTaskMessageLabel.textColor = UIColor.white // 文字色
        todaysTaskMessageLabel.layer.cornerRadius = 10.0 // 角丸のサイズ
        todaysTaskMessageLabel.clipsToBounds = true // labelの時は必須（角丸）
        todaysTaskMessageLabel.layer.borderWidth = 0.0 // 枠線の幅（0なので表示なし）
        todaysTaskMessageLabel.layer.borderColor = UIColor.white.cgColor // 枠線の色
        todaysTaskMessageLabel.backgroundColor = rgba

        //textFieldのデザイン
        textField.borderStyle = .none
        textField.layer.cornerRadius = 17
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1
        textField.layer.masksToBounds = true


        //データ更新処理用コード
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "引っ張ってこうしん！")
        self.refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refreshControl)

        tableView.reloadData()
    }

    //viewが表示される直前の処理
    override func viewWillAppear(_ animated: Bool) {

        self.loadView()
        self.viewDidLoad()
        //インディケータの回転停止
        refreshControl.endRefreshing()
        tableView.reloadData()
        super.viewWillAppear(animated)
        todaysTaskMessageLabelChange()
        textField.text = ""
    }

    //本日のタスクの文言表示処理メソッド
    func todaysTaskMessageLabelChange() {
        if todaysTaskItem.count >= 1 {
            todaysTaskMessageLabel.text = "本日のタスクは\(todaysTaskItem.count)件です"
        } else {
            todaysTaskMessageLabel.text = "本日のタスクはありません"
        }
    }

    //セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todaysTaskItem.count
    }

    //セルを構築する際に呼ばれるメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //カスタムセルを使用
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomTableViewCell
        let object: TodaysTask = self.todaysTaskItem[(indexPath as NSIndexPath).row]

        //セルにタスク名をset
        cell.setCell(titleText: object.name)

        //タスク通知リマインド用画像
        let alarmclockImage = UIImage(named: "alarmClock")! as UIImage
        let alarmImage = UIImage(named: "alarm")! as UIImage
        //セル左側ボタン画像
        let cellImage = UIImage(named: "button1")! as UIImage
        cell.cellImage.image = cellImage
        //タスク登録時アニメーション
        let coinImage = UIImage(named: "star")! as UIImage
        cell.coinImage.image = coinImage
        UIView.animateKeyframes(withDuration: 1.0, delay: 0.0, animations: {
            cell.coinImage.alpha = 1.0
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                cell.coinImage.center.y -= 50.0
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                cell.coinImage.alpha = 0.0
            })
        }, completion: nil)

        //タスク通知がある場合の処理
        if object.time != "設定なし" {
            //砂時計画像をセルに表示させる
            cell.taskNotificationImage.image = alarmclockImage
            //現在時刻比較用
            let convertDate = CommonFunction.dateFromString(string: object.time, format: "yyyy/MM/dd HH:mm")
            //現在時刻のインスタンス化
            let now: Date = Date()
            //該当セルのタスク通知時刻が現在時刻と同時刻か過去であった場合
            if convertDate <= now {
                //画像を更に変更
                cell.taskNotificationImage.image = alarmImage
                //背景も黄色に変更(緊急モード)
                cell.backgroundColor = UIColor.systemYellow
            }
        }
        //それ以外　画像表示と色付けリセット
            else {
                cell.taskNotificationImage.isHidden = true
                cell.backgroundColor = UIColor.clear
        }
        return cell
    }

    //セルが選択(タップ)された時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        textFieldTouchReturnKey = false

        //セルのハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
        //変数indexNumberにセル番号を代入
        indexNumber = indexPath.row
        //タスク詳細画面へ遷移
        performSegue(withIdentifier: "detail", sender: nil)
    }

    //セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height / 8
    }

    //セルをスワイプで削除
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //　削除 || 完了ボタンの共通関数
        func delete () {
            //該当セルのRealmデータオブジェクトの作成
            let object: TodaysTask = self.todaysTaskItem[(indexPath as NSIndexPath).row]
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
                    print(object.id)
                }
            }
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
                    print(object.id)
                }
            }

            //Realm接続　データ削除
            do {
                let realm = try Realm()
                //オブジェクトの取得
                let results = realm.objects(TodaysTask.self)
                print(results)
                try! realm.write {
                    realm.delete(object)
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
                print(results)
            } catch {
                print("本日のタスクを削除できませんでした")
            }
            //本日のタスク件数の再読み込み
            self.todaysTaskMessageLabelChange()
            //データ再読み込み
            tableView.reloadData()
        }

        //スワイプ〜削除ボタンの処理
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
            //削除メソッドの呼び出し
            delete()
        }
        //スワイプ〜完了ボタンの処理
        let doneButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "完了") { (action, index) -> Void in
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
                //レベルアップ画面に遷移
                self.performSegue(withIdentifier: "levelUp", sender: nil)
            }
            //削除メソッドの呼び出し
            delete()
            self.loadView()
            self.viewDidLoad()

        }
        deleteButton.backgroundColor = UIColor.red
        doneButton.backgroundColor = UIColor.blue

        return [deleteButton, doneButton]
    }


//値を次の画面へ渡す処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //セルがタップされた状態(タスク詳細画面の表示)
        if (segue.identifier == "detail") {
            let detailVC = segue.destination as! DetailViewController
            //DetaillVCにセル番号を渡す

            detailVC.saveIndexNumber = indexNumber

        }

        if (segue.identifier == "next") &&
            textFieldTouchReturnKey == false {
            //タップした時にその配列の番号の中身を取り出して値を渡す
            let nextVC = segue.destination as! NextViewController
            //変数名.が持つ変数 =  渡したいものが入った変数
            nextVC.taskNameString = textArray[indexNumber]
        } else if (segue.identifier == "next") && textFieldTouchReturnKey == true {
            //タップした時にその配列の番号の中身を取り出して値を渡す
            let nextVC = segue.destination as! NextViewController
            //遷移先のNextVCのタスク名に、入力したタスク名を表示させる
            nextVC.taskNameString = editText

        }
    }

//returnキーが押された時に発動するメソッド
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        editText = (textField.text?.trimmingCharacters(in: .whitespaces))!
        //タスク名が入力されていない場合キーボード閉じる
        if (editText.isEmpty == true) {
            textField.resignFirstResponder()
        } else {
            textFieldTouchReturnKey = true
            textField.resignFirstResponder()
            //タスク作成画面へ遷移させる
            performSegue(withIdentifier: "next", sender: nil)
        }
        return true
    }
}

