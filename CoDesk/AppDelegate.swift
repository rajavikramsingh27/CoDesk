//  AppDelegate.swift
//  CoDesk
//  Created by iOS-Appentus on 14/May/2020.
//  Copyright © 2020 iOS-Appentus. All rights reserved.


import UIKit
import IQKeyboardManager
import SwiftMessageBar

import GoogleMaps
import GooglePlaces
import GooglePlacesAPI


let apiGoogleKey = ""

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                
        IQKeyboardManager.shared().isEnabled = true
        
        GMSServices.provideAPIKey(apiGoogleKey)
        GMSPlacesClient.provideAPIKey(apiGoogleKey)
        GooglePlaces.provide(apiKey: apiGoogleKey)
        
        let config = SwiftMessageBar.Config.Builder()
            .withErrorColor(hexStringToUIColor("#cc0000"))
         .withSuccessColor(hexStringToUIColor("#00AB66"))
//         .withTitleFont(UIFont (name:"Times New Roman-Bold", size:24.0)!)
//         .withMessageFont(UIFont (name:"Times New Roman-Bold", size: 16.0)!)
         .build()
         
         SwiftMessageBar.setSharedConfig(config)
        
        sleep(4)
        
        return true
    }


}

