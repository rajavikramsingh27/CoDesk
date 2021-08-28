//  SplashViewController.swift
//  CoDesk
//  Created by iOS-Appentus on 14/May/2020.
//  Copyright © 2020 iOS-Appentus. All rights reserved.


import UIKit
import SwiftyJSON


class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = UserDefaults.standard.object(forKey: k_user_detals) {
//            let json = JSON(data_1)
//            print(json)
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier:"tabbar")
            self.navigationController?.pushViewController(vc!, animated:true)
        }
    }
    
    @IBAction func btnLogin(_ sender:UIButton) {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier:"LoginViewController") as! LoginViewController
        navigationController?.pushViewController(loginVC, animated:true)
    }

}
