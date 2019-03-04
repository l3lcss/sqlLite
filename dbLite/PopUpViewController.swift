 //
//  PopUpViewController.swift
//  dbLite
//
//  Created by Admin on 4/3/2562 BE.
//  Copyright © 2562 th.ac.kmutnb.www. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {
    @IBAction func insertBtn(_ sender: Any) {
        let nameSTR = (self.nameTextField.text! as NSString) as String
        let telSTR = (self.telTextField.text! as NSString) as String
        let birthDateSTR = (self.birthDateTextField.text! as NSString) as String
        self.removeAnimate()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "insertNoti"), object: self, userInfo: ["name": nameSTR, "tel": telSTR, "birthDate": birthDateSTR])
        self.view.removeFromSuperview()
    }
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var telTextField: UITextField!
    @IBOutlet weak var birthDateTextField: UITextField!
    
    private var datePicker: UIDatePicker?
    @IBAction func closePopUp(_ sender: Any) {
        self.removeAnimate()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action:
            #selector(PopUpViewController.dateChange(datePicker:)),
            for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PopUpViewController.viewTapped(gestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
        birthDateTextField.inputView = datePicker
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        self.showAnimate()
        // Do any additional setup after loading the view.
    }

    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func dateChange(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        birthDateTextField.text = dateFormatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        });
    }

}
