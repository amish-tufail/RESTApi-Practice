//
//  Model.swift
//  RESTApi-Practice
//
//  Created by Amish on 26/07/2024.
//

import Foundation

struct UserModel: Codable {
    var createdAt: String
    var name: String
    var avatar: String
    var id: String
}



struct NewUser: Codable {
    var createdAt: String
    var name: String
    var avatar: String
}


