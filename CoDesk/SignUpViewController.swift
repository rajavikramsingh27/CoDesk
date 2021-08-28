//  SignUpViewController.swift
//  CoDesk
//  Created by iOS-Appentus on 14/May/2020.
//  Copyright © 2020 iOS-Appentus. All rights reserved.


import UIKit
import SwiftMessageBar
import CoreLocation
import MBProgressHUD

class SignUpViewController: UIViewController {
    @IBOutlet weak var txtFullName:UITextField!
    @IBOutlet weak var txtEmail:UITextField!
    @IBOutlet weak var txtPassword:UITextField!
    
    var co_OrdinateCurrent = CLLocationCoordinate2DMake(0.0, 0.0)
    var locationManager = CLLocationManager()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        func_core_location()
    }
                
    func signup() {
        if co_OrdinateCurrent.latitude == 0.0 {
            return
        } else if co_OrdinateCurrent.longitude == 0.0 {
            return
        }
        
        let param = ["name":txtFullName.text!,
                     "email":txtEmail.text!,
                     "password":txtPassword.text!,
                     "lat":co_OrdinateCurrent.latitude,
                     "lang":co_OrdinateCurrent.longitude] as [String : Any]
        print(param)
        
        MBProgressHUD.showAdded(to:self.view, animated:true)
        APIFunc.postAPI("signup", param) { (json) in
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
                            
                            SwiftMessageBar.showMessage(withTitle:"\(json.dictionaryObject!["message"]!)", message:"", type:.success)
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier:"tabbar")
                                self.navigationController?.pushViewController(vc!, animated:true)
                            })
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
    
    @IBAction func btnLogin(_ sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSignUp(_ sender:UIButton) {
        if txtFullName.text!.isEmpty {
            SwiftMessageBar.showMessage(withTitle: "Error", message: "Enter your full name", type:.error)
        } else if txtEmail.text!.isEmpty {
            SwiftMessageBar.showMessage(withTitle: "Error", message: "Enter email ID", type:.error)
        } else if !txtEmail.text!.isValidEmail() {
            SwiftMessageBar.showMessage(withTitle: "Error", message: "Enter a valid email ID", type:.error)
        } else if txtPassword.text!.isEmpty {
            SwiftMessageBar.showMessage(withTitle: "Error", message: "Enter password", type:.error)
        } else if txtPassword.text!.count < 6 {
            SwiftMessageBar.showMessage(withTitle: "Error", message: "Password length must be greater than 6", type:.error)
        } else {
            signup()
        }
    }
    
}




import CoreLocation


extension SignUpViewController:CLLocationManagerDelegate {
    func func_core_location() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        co_OrdinateCurrent = manager.location!.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}
