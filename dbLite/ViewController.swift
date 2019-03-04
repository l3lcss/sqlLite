//
//  ViewController.swift
//  dbLite
//
//  Created by Admin on 29/1/2562 BE.
//  Copyright © 2562 th.ac.kmutnb.www. All rights reserved.
//

import UIKit
import SQLite3

class ViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBAction func buttonAddDidTap(_ sender: UIBarButtonItem) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpID") as! PopUpViewController
        self.addChild(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
        
//        let alert = UIAlertController(
//            title: "Insert",
//            message: "ใส่ข้อมูลให้ครบทุกช่อง",
//            preferredStyle: .alert
//        )
//
//        alert.addTextField(configurationHandler: { tf in
//            tf.placeholder = "ชื่อ"
//            tf.font = UIFont.systemFont(ofSize: 18)
//        })
//
//        alert.addTextField(configurationHandler: { tf in
//            tf.placeholder = "เบอร์โทร"
//            tf.font = UIFont.systemFont(ofSize: 18)
//            tf.keyboardType = .phonePad
//        })
//
//        let btCancel = UIAlertAction(title: "Cancel",
//                                     style: .cancel,
//                                     handler: nil)
//
//        let btOK = UIAlertAction(title: "OK",
//                                 style: .default,
//                                 handler: { _ in
//                                    self.sql = "INSERT INTO people VALUES (null, ?, ?)"
//                                    sqlite3_prepare(self.db, self.sql, -1, &self.stmt, nil)
//                                    let name = alert.textFields![0].text! as NSString
//                                    let phone = alert.textFields![1].text! as NSString
//                                    sqlite3_bind_text(self.stmt, 1, name.utf8String, -1, nil)
//                                    sqlite3_bind_text(self.stmt, 2, phone.utf8String, -1, nil)
//                                    sqlite3_step(self.stmt)
//
//                                    self.select()
//        })
//        alert.addAction(btCancel)
//        alert.addAction(btOK)
//        present(alert, animated: true, completion: nil)
    }
    @IBAction func buttonEditDidTap(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "Update",
            message: "ใส่ข้อมูลให้ครบทุกช่อง",
            preferredStyle: .alert
        )
        
        alert.addTextField(configurationHandler: { tf in
            tf.placeholder = "ID ของแถวที่ต้องการจะแก้ไข"
            tf.font = UIFont.systemFont(ofSize: 18)
            tf.keyboardType = .numberPad
        })
        
        alert.addTextField(configurationHandler: { tf in
            tf.placeholder = "ชื่อ"
            tf.font = UIFont.systemFont(ofSize: 18)
        })
        
        alert.addTextField(configurationHandler: { tf in
            tf.placeholder = "เบอร์โทร"
            tf.font = UIFont.systemFont(ofSize: 18)
            tf.keyboardType = .phonePad
        })
        
        let btCancel = UIAlertAction(title: "Cancel",
                                     style: .cancel,
                                     handler: nil)
        
        let btOK = UIAlertAction(title: "OK",
                                 style: .default,
                                 handler: { _ in
                                    guard let id = Int32(alert.textFields![0].text!) else {
                                        return
                                    }
                                    let name = alert.textFields![1].text! as NSString
                                    let phone = alert.textFields![2].text! as NSString
                                    self.sql = "UPDATE people " +
                                        "SET name = ?, phone = ? " +
                                        "WHERE id = ?"
                                    sqlite3_prepare(self.db, self.sql, -1, &self.stmt, nil)
                                    sqlite3_bind_text(self.stmt, 1, name.utf8String, -1, nil)
                                    sqlite3_bind_text(self.stmt, 2, phone.utf8String, -1, nil)
                                    sqlite3_bind_int(self.stmt, 3, id)
                                    sqlite3_step(self.stmt)
                                    
                                    self.select()
        })
        alert.addAction(btCancel)
        alert.addAction(btOK)
        present(alert, animated: true, completion: nil)
    }
    @IBAction func buttonDeleteDidTap(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "Delete",
            message: "ใส่ ID ของแถวที่ต้องการลบ",
            preferredStyle: .alert
        )
        
        alert.addTextField(configurationHandler: { tf in
            tf.placeholder = "ID ของแถวที่ต้องการลบ"
            tf.font = UIFont.systemFont(ofSize: 18)
            tf.keyboardType = .numberPad
        })
        
        let btCancel = UIAlertAction(title: "Cancel",
                                     style: .cancel,
                                     handler: nil)
        
        let btOK = UIAlertAction(title: "OK",
                                 style: .default,
                                 handler: { _ in
                                    guard let id = Int32(alert.textFields!.first!.text!) else {
                                        return
                                    }
                                    self.sql = "DELETE FROM people WHERE id = \(id)"
                                    sqlite3_exec(self.db, self.sql, nil, nil, nil)
                                    self.select()
        })
        alert.addAction(btCancel)
        alert.addAction(btOK)
        present(alert, animated: true, completion: nil)
    }
    
    let fileName = "db2.sqlite"
    let fileManager = FileManager.default
    var dbPath = String()
    var sql = String()
    var db: OpaquePointer?
    var stmt: OpaquePointer?
    var pointer: OpaquePointer?
    var insertEvent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(insertFunc(not:)), name: NSNotification.Name(rawValue: "insertNoti"), object: nil)
        
        let dbURL = try! fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
            .appendingPathComponent(fileName)
        let openDb = sqlite3_open(dbURL.path, &self.db)
        if openDb != SQLITE_OK {
            print("Opening Database Error!")
            return
        }
        let sql = "CREATE TABLE IF NOT EXISTS people " +
              "(id INTEGER PRIMARY KEY AUTOINCREMENT, " +
              "name TEXT, " +
              "phone TEXT, " +
              "birth_date TEXT)"
        let createTb = sqlite3_exec(self.db, sql, nil, nil, nil)
        if createTb != SQLITE_OK {
            let err = String(cString: sqlite3_errmsg(db))
            print("err createTb = \(err)")
        }
        select()
    }
    
    @objc func insertFunc(not: Notification) {
        if let userInfo = not.userInfo {
            // Safely unwrap the name sent out by the notification sender
            if let name = userInfo["name"] as? NSString, let tel = userInfo["tel"] as? NSString, let birthDate = userInfo["birthDate"] as? NSString{
                print("userName : \(name)")
                print("tel : \(tel)")
                print("birthDate : \(birthDate)")
                self.sql = "INSERT INTO people VALUES (null, ?, ?, ?)"
                sqlite3_prepare(self.db, self.sql, -1, &self.stmt, nil)
                sqlite3_bind_text(self.stmt, 1, name.utf8String, -1, nil)
                sqlite3_bind_text(self.stmt, 2, tel.utf8String, -1, nil)
                sqlite3_bind_text(self.stmt, 3, birthDate.utf8String, -1, nil)
                sqlite3_step(self.stmt)
                
                self.select()
            }
        }
    }
    
    func select() {
        sql = "SELECT * FROM people"
        sqlite3_prepare(db, sql, -1, &pointer, nil)
        textView.text = ""
        var id: Int32
        var name: String
        var phone: String
        var birthDate: String
        
        while(sqlite3_step(pointer) == SQLITE_ROW) {
            id = sqlite3_column_int(pointer, 0)
            textView.text?.append("id: \(id)\n")
            
            name = String(cString: sqlite3_column_text(pointer, 1))
            textView.text?.append("name: \(name)\n")
            
            phone = String(cString: sqlite3_column_text(pointer, 2))
            textView.text?.append("phone: \(phone)\n")
            
            birthDate = String(cString: sqlite3_column_text(pointer, 3))
            textView.text?.append("birthDate: \(birthDate)\n\n")
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "notificationName"), object: nil)
    }
}
