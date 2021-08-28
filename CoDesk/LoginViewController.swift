//  LoginViewController.swift
//  CoDesk
//  Created by iOS-Appentus on 14/May/2020.
//  Copyright © 2020 iOS-Appentus. All rights reserved.

import UIKit
import SwiftMessageBar
import MBProgressHUD


class LoginViewController: UIViewController {
    @IBOutlet weak var txtEmail:UITextField!
    @IBOutlet weak var txtPassword:UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
        
    @IBAction func btnSignUp(_ sender:UIButton) {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier:"SignUpViewController") as! SignUpViewController
        navigationController?.pushViewController(loginVC, animated:true)
    }

    @IBAction func btnForgotPassword(_ sender:UIButton) {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier:"ForgotPasswordViewController") as! ForgotPasswordViewController
        navigationController?.pushViewController(loginVC, animated:true)
    }

    @IBAction func btnLogin(_ sender:UIButton) {
        if txtEmail.text!.isEmpty {
            SwiftMessageBar.showMessage(withTitle: "Error", message: "Enter email ID", type:.error)
        } else if !txtEmail.text!.isValidEmail() {
            SwiftMessageBar.showMessage(withTitle: "Error", message: "Enter a valid email ID", type:.error)
        } else if txtPassword.text!.isEmpty {
            SwiftMessageBar.showMessage(withTitle: "Error", message: "Enter password", type:.error)
        } else if txtPassword.text!.count < 6 {
            SwiftMessageBar.showMessage(withTitle: "Error", message: "Password length must be greater than 6", type:.error)
        } else {
            login()
        }
    }
    
    func login() {
        let param = ["email":txtEmail.text!,
                     "password":txtPassword.text!]
        print(param)
        
        MBProgressHUD.showAdded(to:self.view, animated:true)
        APIFunc.postAPI("login", param) { (json) in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for:self.view, animated:true)
                
                if json.dictionaryObject == nil {
                    return
                }
                let status = return_status(json.dictionaryObject!)
                print(json.dictionaryObject!)
                
                switch status {
                case .success:
                    let decoder = JSONDecoder()
                    if let jsonData = json[result_resp].description.data(using: .utf8) {
                        do {
                            signUp = try decoder.decode([SignUp].self, from: jsonData)
                            
                            UserDefaults.standard.setValue(signUp[0].id, forKey:k_user_detals)
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier:"tabbar")
                            self.navigationController?.pushViewController(vc!, animated:true)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                case .fail:
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                        SwiftMessageBar.showMessage(withTitle:"\(json.dictionaryObject!["message"]!)", message:"", type:.error)
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
