//  FavoriteViewController.swift
//  CoDesk
//  Created by iOS-Appentus on 23/May/2020.
//  Copyright © 2020 iOS-Appentus. All rights reserved.


import UIKit


let kFavorite = "Favorite"


class FavoriteViewController: UIViewController {
    @IBOutlet weak var tblList:UITableView!
    var arrUsers = [[String:String]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
        
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated:false)
        
        reloadUI()
    }
    
    func reloadUI() {
        
        arrUsers = [[String:String]]()
        if let userDefault = UserDefaults.standard.object(forKey:kFavorite) as? Data {
            arrUsers = NSKeyedUnarchiver.unarchiveObject(with: userDefault) as! [[String:String]]
        }
        tblList.isHidden = arrUsers.count == 0 ? true : false
        tblList.reloadData()
    }
    
}



extension FavoriteViewController:UITableViewDelegate,UITableViewDataSource {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrUsers.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for:indexPath) as! DashboardTableViewCell
        
        let users = arrUsers[indexPath.row]
        cell.imgProfile.sd_setImage(with: URL(string:"\(users["icon"]!)"), placeholderImage:kDefaultUser)
        cell.lblUserName.text = "\(users["name"]!)"
        cell.lblPost.text = "\(users["vicinity"]!)"
        
        cell.btnHeart.isSelected = true
        cell.btnHeart.tag = indexPath.row
        cell.btnHeart.addTarget(self, action:#selector(btnUnfavorite(_:)), for:.touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated:true)
    }
    
    @IBAction func btnUnfavorite(_ sender:UIButton) {
        var arrUsers = [[String:String]]()
        
        if let userDefault = UserDefaults.standard.object(forKey:kFavorite) as? Data {
            arrUsers = NSKeyedUnarchiver.unarchiveObject(with: userDefault) as! [[String:String]]
            arrUsers.remove(at:sender.tag)
        }
        
        let placesData = NSKeyedArchiver.archivedData(withRootObject: arrUsers)
        UserDefaults.standard.set(placesData, forKey:kFavorite)
        
        reloadUI()
    }
    
}


