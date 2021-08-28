//
//  ProfileViewController.swift
//  CoDesk
//
//  Created by iOS-Appentus on 15/May/2020.
//  Copyright © 2020 iOS-Appentus. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyJSON
import SwiftMessageBar
import SDWebImage

var isReloadUserProfile = false

class ProfileViewController: UIViewController {
    @IBOutlet weak var imgProfile:UIImageView!
    @IBOutlet weak var txtUserName:UITextField!
    @IBOutlet weak var txtpost:UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated:false)
        
        if isReloadUserProfile {
            get_user_profile()
        }
    }
        
    func get_user_profile() {
        var param = [String:String]()
        if let userId = UserDefaults.standard.object(forKey: k_user_detals) as? String {
            param = ["user_id":userId]
            print(param)
        }
        
        MBProgressHUD.showAdded(to:self.view, animated:true)
        APIFunc.postAPI("get_user_profile", param) { (json) in
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
                            
                            self.imgProfile.sd_setImage(with: URL(string:signUp[0].profile.userProfile), placeholderImage:kDefaultUser)
                            self.txtUserName.text = signUp[0].name
                            self.txtpost.text = signUp[0].post
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
    
    func update_user_profile() {
        var param = [String:String]()
        if let userId = UserDefaults.standard.object(forKey:k_user_detals) as? String {
            param = ["user_id":userId,
                     "user_name":txtUserName.text!,
                     "post":txtpost.text!]
            print(param)
        }
        print(param)
        
        MBProgressHUD.showAdded(to:self.view, animated:true)
        let dataImage = imgProfile.image?.jpegData(compressionQuality:0.3)
        APIFunc.postAPI_Image("update_user_profile", dataImage, param, "file") { (json) in
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
    
    
    
    @IBAction func btnLogOut(_ sender: UIButton) {
        let alertVC = UIAlertController (title:"Are you sure?", message:"Do you want to log out ?", preferredStyle:.actionSheet)
        
        alertVC.addAction(UIAlertAction(title:"Log Out", style:.default, handler: { (logout) in
            UserDefaults.standard.removeObject(forKey:k_user_detals)
            
            let sideMenuViewController = self.storyboard?.instantiateViewController(withIdentifier:"LoginViewController") as! LoginViewController
            let navigationViewController: UINavigationController = UINavigationController(rootViewController:sideMenuViewController)
            let appedl = UIApplication.shared.delegate as! AppDelegate
            appedl.window?.rootViewController = navigationViewController
            
            appedl.window?.makeKeyAndVisible()
        }))
        
        alertVC.addAction(UIAlertAction(title:"Cancel", style:.cancel, handler: { (logout) in
            
        }))
        
        present(alertVC, animated:true, completion:nil)
    }
    
    @IBAction func btnUpdateProfile(_ sender: UIButton) {
        if txtUserName.text!.isEmpty {
            SwiftMessageBar.showMessage(withTitle: "Error", message: "Enter user name", type:.error)
        } else if txtpost.text!.isEmpty {
            SwiftMessageBar.showMessage(withTitle: "Error", message: "Enter your post", type:.error)
        } else {
            update_user_profile()
        }
    }
    
    
}



extension ProfileViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate  {
    @IBAction func btnEdit(_ sender: UIButton) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            //            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        isReloadUserProfile = false
        if let image = info[.originalImage] as? UIImage {
            imgProfile.image = image
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isReloadUserProfile = false
        picker.dismiss(animated: true, completion: nil)
    }
    
}
