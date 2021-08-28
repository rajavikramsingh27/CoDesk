//  DashboardViewController.swift
//  CoDesk
//  Created by iOS-Appentus on 15/May/2020.
//  Copyright © 2020 iOS-Appentus. All rights reserved.


import UIKit
import MapKit
import SwiftMessageBar
import MBProgressHUD
import CoreLocation
import SDWebImage
import SwiftyJSON



class DashboardViewController: UIViewController {
    @IBOutlet weak var viewPicker:UIView!
    @IBOutlet weak var tblList:UITableView!
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var pickerView:UIPickerView!
    @IBOutlet weak var lblSelectedRadius:UILabel!
    @IBOutlet weak var txtSearchByLocation:UITextField!
    
    var selectedRadius = "5"
    
    var arrRadius = [String]()
    
    var co_OrdinateCurrent = CLLocationCoordinate2DMake(0.0, 0.0)
    var locationManager = CLLocationManager()
    
    var isLocation = false
    
    var arrGoogleResults = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblList.isHidden = true
        mapView.isHidden = false
        viewPicker.isHidden = true
        
        func_core_location()
        
        for i in 0..<100 {
            arrRadius.append("\(i+1)")
        }
        pickerView.reloadAllComponents()
        
        lblSelectedRadius.text = "5 km"
        
        txtSearchByLocation.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated:false)
        
        isReloadUserProfile = true
//        get_users()
        
        if co_OrdinateCurrent.latitude != 0.0 || co_OrdinateCurrent.longitude != 0.0 {
            getCoworkersFromGoogle(co_OrdinateCurrent,String(Int64(selectedRadius)!*Int64(100)))
        }
    }
    
    func setPin() {
        for user in arrGoogleResults {
            let annotation = MKPointAnnotation()
            annotation.title = "\(user["name"]!)"
            annotation.subtitle = "\(user["vicinity"]!)"
            
            if let geometry = user["geometry"] as? [String:Any] {
                if let location = geometry["location"] as? [String:Any] {
                    let lat = Double("\(location["lat"]!)")!
                    let lng = Double("\(location["lng"]!)")!
                    
                    annotation.coordinate = CLLocationCoordinate2D (latitude:lat, longitude:lng)
                    mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    @IBAction func btnPickerDone(_ sender:UIButton) {
        viewPicker.isHidden = true
        lblSelectedRadius.text = selectedRadius + " km"
//        get_users()
        getCoworkersFromGoogle(co_OrdinateCurrent,String(Int64(selectedRadius)!*Int64(100)))
    }
    
    @IBAction func btnPickerCancel(_ sender:UIButton) {
        viewPicker.isHidden = true
    }
    
    @IBAction func btnRadius(_ sender:UIButton) {
        viewPicker.isHidden = false
    }
    
    @IBAction func segment(_ sender:UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            tblList.isHidden = true
            mapView.isHidden = false
        } else if sender.selectedSegmentIndex == 1 {
            tblList.isHidden = false
            mapView.isHidden = true
        }
    }
    
    func getCoworkersFromGoogle(_ cord:CLLocationCoordinate2D,_ selectedRadius:String) {
        MBProgressHUD.showAdded(to:self.view, animated:true)
        let googleAPI = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(cord.latitude),\(cord.longitude)&radius=\(selectedRadius)&type=coworkers&keyword=coworkers&key=\(apiGoogleKey)"
        
        APIFunc.getAPIWithoutBaseURL(googleAPI) { (json) in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for:self.view, animated:true)
                
                if json.dictionaryObject == nil {
                    return
                }
                print(json.dictionaryObject!)
                
                if let googleResults = json.dictionaryObject?["results"] as? [[String:Any]] {
                    self.arrGoogleResults = googleResults
                }
                self.tblList.reloadData()
                self.setPin()
            }
        }
    }
    
    
    
//    func get_users() {
//        let param = ["lat":co_OrdinateCurrent.latitude,"long":co_OrdinateCurrent.longitude,"radius":"5"] as [String : Any]
////        let param = ["lat":"26.75321","long":"75.2356","radius":"5"] as [String : Any]
//        print(param)
//
//        MBProgressHUD.showAdded(to:self.view, animated:true)
//        APIFunc.postAPI("get_users", param) { (json) in
//            DispatchQueue.main.async {
//                MBProgressHUD.hide(for:self.view, animated:true)
//
//                if json.dictionaryObject == nil {
//                    return
//                }
//                let status = return_status(json.dictionaryObject!)
//                print(json.dictionaryObject!)
//
//                switch status {
//                case .success:
//                    let decoder = JSONDecoder()
//                    if let jsonData = json[result_resp].description.data(using: .utf8) {
//                        do {
//                            getUsers = try decoder.decode([GetUser].self, from: jsonData)
//                            self.tblList.reloadData()
//
//                            self.setPin()
//                        } catch {
//                            print(error.localizedDescription)
//                        }
//                    }
//                case .fail:
//                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
//                        SwiftMessageBar.showMessage(withTitle:"\(json.dictionaryObject!["message"]!)", message:"", type:.error)
//                    })
//                case .error_from_api:
//                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
//                        SwiftMessageBar.showMessage(withTitle: "Error", message:"\(json["Error from API"])", type:.error)
//                    })
//                }
//            }
//        }
//    }
    
}



extension DashboardViewController:UITableViewDelegate,UITableViewDataSource {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrGoogleResults.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for:indexPath) as! DashboardTableViewCell
        
        let dictUser = self.arrGoogleResults[indexPath.row]
        cell.imgProfile.sd_setImage(with: URL(string:"\(dictUser["icon"]!)"), placeholderImage:kDefaultUser)
        cell.lblUserName.text = "\(dictUser["name"]!)"
        cell.lblPost.text = "\(dictUser["vicinity"]!)"
        
        cell.btnHeart.tag = indexPath.row
        
        if let userDefault = UserDefaults.standard.object(forKey:kFavorite) as? Data {
            let arrSelected = NSKeyedUnarchiver.unarchiveObject(with: userDefault) as! [[String:String]]
                        
            if arrSelected.count > 0 {
                for i in 0..<arrSelected.count {
                    let user = arrSelected[i]
                    
                    if "\(dictUser["id"]!)" == "\(user["id"]!)" {
                        cell.btnHeart.isSelected = true
                        cell.btnHeart.addTarget(self, action:#selector(btnUnFavoriite(_:)), for:.touchUpInside)
                        
                        break
                    } else {
                        cell.btnHeart.isSelected = false
                        cell.btnHeart.addTarget(self, action:#selector(btnHeart(_:)), for:.touchUpInside)
                    }
                }
            } else {
                cell.btnHeart.isSelected = false
                cell.btnHeart.addTarget(self, action:#selector(btnHeart(_:)), for:.touchUpInside)
            }
        } else {
            cell.btnHeart.isSelected = false
            cell.btnHeart.addTarget(self, action:#selector(btnHeart(_:)), for:.touchUpInside)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated:true)
    }
    
    @IBAction func btnHeart (_ sender:UIButton) {
        let userGet = self.arrGoogleResults[sender.tag]
        var arrUsers = [[String:String]]()
        
        if let userDefault = UserDefaults.standard.object(forKey:kFavorite) as? Data {
            let placesArray = NSKeyedUnarchiver.unarchiveObject(with: userDefault) as! [[String:String]]
            
            for i in 0..<placesArray.count {
                let user = placesArray[i]
                var dictUsers = [String:String]()
                dictUsers["id"] = user["id"]
                dictUsers["icon"] = user["icon"]
                dictUsers["name"] = user["name"]
                dictUsers["vicinity"] = user["vicinity"]
                
                arrUsers.append(dictUsers)
            }
        }
        
        var dictUsers = [String:String]()
        dictUsers["id"] = "\(userGet["id"]!)"
        dictUsers["icon"] = "\(userGet["icon"]!)"
        dictUsers["name"] = "\(userGet["name"]!)"
        dictUsers["vicinity"] = "\(userGet["vicinity"]!)"
        
        arrUsers.append(dictUsers)
        
        print(arrUsers)
        
        let placesData = NSKeyedArchiver.archivedData(withRootObject: arrUsers)
        UserDefaults.standard.set(placesData, forKey:kFavorite)
        
        tblList.reloadData()
    }
    
    @IBAction func btnUnFavoriite (_ sender:UIButton) {
        let userGet = self.arrGoogleResults[sender.tag]
        var arrUsers = [[String:String]]()
        
        if let userDefault = UserDefaults.standard.object(forKey:kFavorite) as? Data {
            arrUsers = NSKeyedUnarchiver.unarchiveObject(with: userDefault) as! [[String:String]]
            
            for i in 0..<arrUsers.count {
                let user = arrUsers[i]
                
                if "\(userGet["id"]!)" == "\(user["id"]!)" {
                    arrUsers.remove(at:i)
                    break
                }
            }
        }
        
        let placesData = NSKeyedArchiver.archivedData(withRootObject: arrUsers)
        UserDefaults.standard.set(placesData, forKey:kFavorite)
        
//        get_users()
        getCoworkersFromGoogle(co_OrdinateCurrent,String(Int64(selectedRadius)!*Int64(100)))
    }
    
}



extension DashboardViewController:UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrRadius.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(arrRadius[row]) km"
    }
     
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRadius = arrRadius[row]
    }
    
}



extension DashboardViewController:CLLocationManagerDelegate {
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
        
        if !isLocation {
            isLocation = true
            let mapCamera = MKMapCamera(lookingAtCenter:co_OrdinateCurrent, fromDistance:5, pitch:5, heading: 0)
            mapView.setCamera(mapCamera, animated: true)
            
//            get_users()
            getCoworkersFromGoogle(co_OrdinateCurrent,String(Int64(selectedRadius)!*Int64(100)))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}



import GooglePlaces
extension DashboardViewController: GMSAutocompleteViewControllerDelegate,UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
        
        return false
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        co_OrdinateCurrent = place.coordinate
        getCoworkersFromGoogle(co_OrdinateCurrent,String(Int64(selectedRadius)!*Int64(100)))
        
        dismiss(animated: true, completion: nil)
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }

    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}
