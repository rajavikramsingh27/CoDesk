//  ForgotPasswordViewController.swift
//  CoDesk
//  Created by iOS-Appentus on 15/May/2020.
//  Copyright © 2020 iOS-Appentus. All rights reserved.


import UIKit
import SwiftMessageBar
import MBProgressHUD


class ForgotPasswordViewController: UIViewController {
    @IBOutlet weak var txtEmail:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    @IBAction func btnReset(_ sender:UIButton) {
        if txtEmail.text!.isEmpty {
            SwiftMessageBar.showMessage(withTitle: "Error", message: "Enter email ID", type:.error)
        } else if !txtEmail.text!.isValidEmail() {
            SwiftMessageBar.showMessage(withTitle: "Error", message: "Enter a valid email ID", type:.error)
        } else {
            forget_password()
        }
    }
    
    func forget_password() {
        let param = ["email":txtEmail.text!]
        print(param)
        
        MBProgressHUD.showAdded(to:self.view, animated:true)
        APIFunc.postAPI("forget_password", param) { (json) in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for:self.view, animated:true)
                
                if json.dictionaryObject == nil {
                    return
                }
                let status = return_status(json.dictionaryObject!)
                print(json.dictionaryObject!)
                
                switch status {
                case .success:
                    SwiftMessageBar.showMessage(withTitle:"\(json.dictionaryObject!["Message"]!)", message:"", type:.success)
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                        self.btnBack("")
                    })
                case .fail:
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                        SwiftMessageBar.showMessage(withTitle:"\(json.dictionaryObject!["Message"]!)", message:"", type:.error)
                    })
                case .error_from_api:
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                        SwiftMessageBar.showMessage(withTitle: "Error", message:"\(json["Error from API"])", type:.error)
                    })
                }
            }
        }
    }

}
