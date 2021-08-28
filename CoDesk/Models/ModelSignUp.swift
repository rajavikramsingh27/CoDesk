//  ModelSignUp.swift
//  CoDesk
//  Created by iOS-Appentus on 20/May/2020.
//  Copyright © 2020 iOS-Appentus. All rights reserved.


import Foundation


// MARK: - ModelSignUpElement
struct SignUp: Codable {
    let id, profile, name, post: String
    let email, password, passwordString, lat: String
    let long, created: String

    enum CodingKeys: String, CodingKey {
        case id, profile, name, post, email, password
        case passwordString = "password_string"
        case lat, long, created
    }
}

var signUp:[SignUp] = []
