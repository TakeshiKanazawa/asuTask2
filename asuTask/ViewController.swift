//
//  ViewController.swift
//  asuTask
//
//  Created by 金澤武士 on 2019/09/28.
//  Copyright © 2019 tk. All rights reserved.
//

import UIKit
import UserNotifications

extension Date {
    //引数で指定した日付からの秒数を返す
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
}


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ReloadProtocol, DateProtocol, setidProtocol,UNUserNotificationCenterDelegate,setTimeProtocol,setPriorityProtocol,setTaskTimeforDetailViewProtocol {

    var notificationGranted = true
    var dateTime = Date()

    //タスク入力用テキストフィールド
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var taskAllDone: UIButton!
    @IBOutlet weak var taskAllDelete: UIButton!
    //テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    //タスク件数表示用ラベル
    @IBOutlet weak var todaysTaskMessageLabel: UILabel!
    //リターンキーが押されたかどうかを判定する
    var textFieldTouchReturnKey = false
    //タスク名を入れる配列
    var textArray = [String]()

    //タスク登録時刻を入れる配列
    var taskTimeArray = [String]()
    //タスク登録時刻を入れる配列(detailview用)
    var taskTimeArrayforDetailview = [String]()
    //タスク優先度を入れる配列
    var taskPriorityArray = [String]()
    //checkされたタスク(セル)の配列を入れておくための配列
    var checkedTaskArray = [IndexPath]()
     //タスクのIdentifierを入れるための配列
    var idArray = [String]()
    //選択されたセルの番号を入れるための変数
    var indexNumber = Int()
    //入力されたタスクを入れる変数
    var editText = String()
    //content badge用変数
    var contentBadgeInt = Int()
    
    var refreshControl:UIRefreshControl!
     var isRefresh = false
    @objc func refresh()
    {

       // 更新するコード(webView.reload()など)
        refreshControl.endRefreshing()
        tableView.reloadData()

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableview　⇨ viewcontroller へ処理を任せる
        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
        
   self.refreshControl = UIRefreshControl()
       
   self.refreshControl.attributedTitle = NSAttributedString(string: "こうしん中！")
        self.refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)

   self.tableView.addSubview(refreshControl)
        tableView.reloadData()
        
//
//        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        //appDelegate.viewController = self
        
        //タスク完了ボタンの非表示
        taskAllDone.isHidden = true
        //タスク全削除ボタンの非表示
        taskAllDelete.isHidden = true

    }
    
//画面タッチでキーボード閉じる(ios13から機能しない？？)
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//            textField.resignFirstResponder()
//        }

    //フォアグラウンドでも通知を表示する設定
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler([.alert, .badge, .sound])
    }

    //viewが表示される直前の処理
    override func viewWillAppear(_ animated: Bool) {
        //インディケータのくるくる止める
        refreshControl.endRefreshing()
        tableView.reloadData()
        super.viewWillAppear(animated)
        todaysTaskMessageLabelChange()
        textField.text = ""
    }

    //本日のタスクの文言表示処理メソッド
    func todaysTaskMessageLabelChange() {
        //本日のタスクが１件以上なら「本日のタスクは〇〇件です」と表示
        if textArray.count >= 1 {
            todaysTaskMessageLabel.text = "本日のタスクは\(textArray.count)件です"
            //本日のタスクがない場合(0件)
        } else {
            todaysTaskMessageLabel.text = "本日のタスクはありません"
        }
    }
    //Date型　⇨ String型へ変換を行うメソッド
      func dateFromString(string: String, format: String) -> Date {
         let formatter: DateFormatter = DateFormatter()
         formatter.calendar = Calendar(identifier: .gregorian)
         formatter.dateFormat = format
        return formatter.date(from: string)!
    }

    //nextVCで完了ボタンが押されたら呼ばれるメソッド
    func reloadSystemData(checkCount: Int) {
        if checkCount == 1 {
            //textArrayにタスク追加
            textArray.append(textField.text!)

            //tableView再読み込み
            tableView.reloadData()
        }
    }
    //NextVCよりデリゲートされたメソッド群
    func setId(id: String) {
        idArray.append(id)
        print(idArray)
    }
    
    func setTaskTime(time: String) {
        taskTimeArray.append(time)
        print(taskTimeArray)
    }
    func setTaskTimeforDetailView(time: String) {
        taskTimeArrayforDetailview.append(time)
        print(taskTimeArrayforDetailview)
    }
    func setTaskPriority(priority: String) {
        taskPriorityArray.append(priority)
      }
    
     //セクションのセルの数
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            //セルの数を配列の数と同じにする
            return textArray.count
        }

        //セクション数(今回は1つ)
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
    @IBAction func checkButton(_ sender: CheckBox) {
    
    //checkBoxのボタン
        let cell = sender.superview?.superview as! CustomTableViewCell
        let indexPath = self.tableView.indexPath( for: cell )

        //チェックがついていた時の処理
        if sender.isChecked == false{
            //タスク完了ボタンの非表示
            taskAllDone.isHidden = false
            //タスク全削除ボタンの非表示
            taskAllDelete.isHidden = false
        //checkしたタスクのセルを配列に追加
        checkedTaskArray.append(indexPath!)
            print(checkedTaskArray)
            print(true)
        } else {
            //タスク完了ボタンの非表示
             taskAllDone.isHidden = true
             //タスク全削除ボタンの非表示
             taskAllDelete.isHidden = true
            checkedTaskArray.remove(at: indexPath!.row)
            print(checkedTaskArray)
        }

        }

    //タスク全完了ボタンを押下した時
    @IBAction func taskAllDone(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: "タスクの全完了", message: "チェック済みのタスクを全て完了にしても宜しいですか？", preferredStyle:  UIAlertController.Style.actionSheet)
        // OKボタン
        let defaultAction_1: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
        //ボタン押下時の処理
            print("OK")
        })


        // アラートの表示拒否ボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "今後このメッセージを表示しない", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
        //ボタン押下時の処理
            print("removeAction")
        })

        // キャンセルボタン
        let destructiveAction_1: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.destructive, handler:{
            (action: UIAlertAction!) -> Void in
            print("caccelAction_1")
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction_1)
        alert.addAction(destructiveAction_1)

           // ④ Alertを表示
        present(alert, animated: true, completion: nil)
        
    }

    //タスク全削除ボタンを押下した時
    @IBAction func taskAllDelete(_ sender: Any) {
       let alert: UIAlertController = UIAlertController(title: "タスクの全削除", message: "チェック済みのタスクを全て削除しても宜しいですか？", preferredStyle:  UIAlertController.Style.actionSheet)
       // OKボタン
       let defaultAction_1: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
           (action: UIAlertAction!) -> Void in
       //ボタン押下時の処理
           print("OK")
       })

       // アラートの表示拒否ボタン
       let cancelAction: UIAlertAction = UIAlertAction(title: "今後このメッセージを表示しない", style: UIAlertAction.Style.cancel, handler:{
           (action: UIAlertAction!) -> Void in
       //ボタン押下時の処理
           print("removeAction")
       })

       // キャンセルボタン
       let destructiveAction_1: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.destructive, handler:{
           (action: UIAlertAction!) -> Void in
           print("caccelAction_1")
       })
       alert.addAction(cancelAction)
       alert.addAction(defaultAction_1)
       alert.addAction(destructiveAction_1)

          // ④ Alertを表示
       present(alert, animated: true, completion: nil)
    }
    
    
    //セルを構築する際に呼ばれるメソッド
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            //カスタムセルを使用
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomTableViewCell
            print(textArray[indexPath.row])
            cell.setCell(titleText: textArray[indexPath.row])
            
            //タスク通知リマインド用画像
            let clockImage = UIImage(named: "clock")! as UIImage
            let sunImage = UIImage(named: "sun")! as UIImage
            
            //タスク通知があれば
            if taskTimeArray[indexPath.row] != "設定なし"{
                //砂時計画像をセルに表示させる
                cell.taskNotificationImage.image = clockImage
                //現在時刻比較用
                let convertDate = self.dateFromString(string: self.taskTimeArray[indexPath.row], format:  "yyyy/MM/dd HH:mm")
                //現在時刻のインスタンス化
                     let now : Date = Date()
                //該当セルのタスク通知時刻が現在時刻と同時刻か過去であった場合
                if convertDate <= now  {
                //画像を更に変更
                    cell.taskNotificationImage.image = sunImage
                //背景も赤に変更(緊急モード)
                    cell.backgroundColor = UIColor.red
                }
            }

                //それ以外は画像を表示しない
                
            else {
                
                cell.taskNotificationImage.isHidden = true
                
            }

            return cell
            
        }
    
    //セルが選択(タップ)された時
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            textFieldTouchReturnKey = false
            //セルのハイライト解除
            tableView.deselectRow(at: indexPath, animated: false)
            //変数indexNumberにセル番号を代入
           indexNumber = indexPath.row
            print(indexNumber)
            //タスク詳細画面へ遷移
            performSegue(withIdentifier: "detail", sender: nil)
            
        }

        //セルの高さ
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return view.frame.size.height / 8
        }

        //セルをスワイプで削除
        func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
            let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
                
                  let center = UNUserNotificationCenter.current()
                center.removePendingNotificationRequests(withIdentifiers: [self.idArray[indexPath.row]])
                
                print(self.idArray[indexPath.row])
                    self.textArray.remove(at: indexPath.row)
                   self.idArray.remove(at: indexPath.row)
                print(self.idArray)
                //tasktimeArrayから削除セルの時刻をprint
                print(self.taskTimeArray[indexPath.row])
               
               //タスク通知のあるタスクかcheck
                if self.taskTimeArray[indexPath.row] != "設定なし" { //登録時刻が現在時刻よりも後の場合はタスク削除時にバッジもデクリメントする。
                
                //まず登録時刻をDate型に変換
                let convertDate = self.dateFromString(string: self.taskTimeArray[indexPath.row], format:  "yyyy/MM/dd HH:mm")
                //現在時刻のインスタンス化
                let now : Date = Date()
                //現在時刻と比較
                //登録時刻が現在時刻と過去である、もしくは同時刻であった場合
                if convertDate <= now  {
                //バッジをデクリメント
                UIApplication.shared.applicationIconBadgeNumber -= 1
                }
                }
                //セルの削除
                tableView.deleteRows(at: [indexPath], with: .fade)
                //本日のタスク件数の再読み込み
                self.todaysTaskMessageLabelChange()
                }
              let doneButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "完了") { (action, index) -> Void in
                  //ここに完了ボタンを押した時の処理を書く！
                    
            }
                deleteButton.backgroundColor = UIColor.red
            doneButton.backgroundColor = UIColor.blue
            
 return [deleteButton,doneButton]
        
    }

    func setDateSystem(date: Date) {

        //プッシュ通知認証許可フラグ
        var isFirst = true
        //デリゲートメソッドを設定
        UNUserNotificationCenter.current().delegate = self
        //Push通知の許可を表示(アラート、サウンド、バッジ)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            self.notificationGranted = granted

            if let error = error {
                print("エラーです")
            }
            self.setNotification(date: date)
        }
        isFirst = false
    }

    func setNotification(date: Date) {

        //コンテントバッジをインクリメント
        contentBadgeInt += 1
        //通知日時の設定
        var trigger: UNNotificationTrigger
        //タスク通知名の設定
        let taskNotificationName = textArray[indexNumber]
        //noticficationtimeにdatepickerで取得した値をset
        let notificationTime = Calendar.current.dateComponents(in: TimeZone.current, from: date)
        //現在時刻の取得
        let now = Date()
        //変数taskedDateに取得日時をDatecomponens型で代入
        let taskDate = DateComponents(calendar: .current, year: notificationTime.year, month: notificationTime.month, day: notificationTime.day, hour: notificationTime.hour, minute: notificationTime.minute).date!
        //変数secondsに現在時刻とタスク通知日時の差分の秒数を代入
        let seconds = taskDate.seconds(from: now)
        //Task通知秒数のTEST出力用
        print(seconds)
        //triggerに現在時刻から〇〇秒後のタスク実行時間をset
        trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        //タスク通知内容の設定
        let content = UNMutableNotificationContent()
        content.title = "\(taskNotificationName)"
        content.body = "タスクのお知らせ"
        content.sound = .default
        //バッジにNSNumber型でcontentBadgeIntを代入
        content.badge = contentBadgeInt as NSNumber
        //ユニークIDの設定
        let identifier = NSUUID().uuidString
        //登録用リクエストの設定
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        print(identifier)
        idArray.append(identifier)
        print(idArray)
        
        //通知をセット
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
<<<<<<< HEAD
=======
         UIApplication.shared.applicationIconBadgeNumber += 1

>>>>>>> 4492bf0ae93e87b6464c75b8c41c64062b858900
    }
   
    //値を次の画面へ渡す処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //セルがタップされた状態(タスク詳細画面の表示)
            
                if (segue.identifier == "detail") {
                    let detailVC: DetailViewController = (segue.destination as? DetailViewController)!
        
        //ここでタップされたセルのindexNumberを取得しなければいけない
                    detailVC.taskNameString = textArray[indexNumber]
                    detailVC.taskTimeString = taskTimeArrayforDetailview[indexNumber]
                    detailVC.taskPriorityString = taskPriorityArray[indexNumber]
                    
                    print(taskTimeArray[indexNumber])
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
            //デリゲート元の設定
            nextVC.reloadData = self
            nextVC.dateProtol = self
            nextVC.setId = self
            nextVC.setTime = self
            nextVC.setPriority = self
            nextVC.setTaskTimeforDetailViewProtocol = self
        }
    }
    
    //returnキーが押された時に発動するメソッド
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        editText = (textField.text?.trimmingCharacters(in: .whitespaces))!
        //タスク名が入力されていない場合キーボード閉じる
        if (editText.isEmpty == true){
             textField.resignFirstResponder()
        }else {
        textFieldTouchReturnKey = true
        textField.resignFirstResponder()
        //タスク作成画面へ遷移させる
        performSegue(withIdentifier: "next", sender: nil)
        }
        return true

    }
}

