//
//  User.swift
//  GithubAPI
//
//  Created by Kiran Kumar Sanka on 3/28/18.
//  Copyright © 2018 Kiran Kumar Sanka. All rights reserved.
//

import Foundation

class User: Codable {
    
    static let dateFormatter = DateFormatter()

    let name:String
    let fullName:String
    let created:Date?
    let description:String?
    let license:License?
    
    enum CodingKeys: String, CodingKey {
        case name
        case fullName = "full_name"
        case created = "created_at"
        case description
        case license
    }
}
