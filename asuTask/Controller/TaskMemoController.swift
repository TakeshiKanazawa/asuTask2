//
//  TaskMemoController.swift
//  asuTask
//
//  Created by 金澤武士 on 2019/10/03.
//  Copyright © 2019 tk. All rights reserved.
//

import UIKit
import RealmSwift

class TaskMemoController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate {

    //Realm
    var taskMemoItem: Results<TaskMemo>!


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!

    //リターンキーが押されたかどうかを判定する
    var textFieldTouchReturnKey = false

    //画面タッチでキーボード閉じる
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            textField.resignFirstResponder()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //TodaysTaskクラスに永続化されているデータを取りだす
        do {
            let realm = try Realm()
            taskMemoItem = realm.objects(TaskMemo.self)
            //tableView.reloadData()
        } catch {
            print("RealmからTaskMemoのデータを読み込めませんでした")
        }


        //タップでキーボード閉じる
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(TaskMemoController.tapped(_:)))
        //tableviewへのtapを検知させる
        tapGesture.cancelsTouchesInView = false

        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)


    }

    //セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return taskMemoItem.count

    }
    //セルを構築する際に呼ばれるメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //カスタムセルを使用
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskMemoCell")
        let object: TaskMemo = self.taskMemoItem[(indexPath as NSIndexPath).row]

        //セルにタスク名をset
        cell?.textLabel!.text = object.name

        return cell!
    }

    //セルが選択(タップ)された時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        textFieldTouchReturnKey = false

        //self.tableView.allowsSelection = false

    }

    //セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height / 14
    }

    //セルをスワイプで削除
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in

            //該当セルのRealmデータオブジェクトの作成
            let object: TaskMemo = self.taskMemoItem[(indexPath as NSIndexPath).row]

            //Realm接続　データ削除
            do {
                let realm = try Realm()

                try! realm.write {
                    realm.delete(object)
                }
            } catch {
                print("本日のタスクを削除できませんでした")
            }

            //realmからタスクメモ１件削除

            tableView.deleteRows(at: [indexPath], with: .automatic)
            //tableviewおよびviewの再読み込み
            tableView.reloadData()

        }
        deleteButton.backgroundColor = UIColor.red

        return [deleteButton]
    }

    //returnキーが押された時に発動するメソッド
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        editText = (textField.text?.trimmingCharacters(in: .whitespaces))!
        //タスク名が入力されていない場合キーボード閉じる
        if (editText.isEmpty == true) {
            textField.resignFirstResponder()
        } else {
            textFieldTouchReturnKey = true
            //キーボード閉じる
            textField.resignFirstResponder()

            //realmへ該当タスク登録
            //ここでRMに接続し、データの保存を行う
            let newTaskMemo = TaskMemo()
            newTaskMemo.name = textField.text!

            do {
                let realm = try Realm()
                try realm.write({ () -> Void in
                    realm.add(newTaskMemo)
                    print("タスクメモ1件保存完了")
                })
            } catch {
                print("タスクメモ1件保存失敗")
            }
            //テキストフィールドの文字を空にする
            textField.text = ""
            //tableviewおよびviewの再読み込み
            tableView.reloadData()
            loadView()
            viewDidLoad()

        }
        return true
    }
}
