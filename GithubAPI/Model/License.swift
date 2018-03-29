//
//  License.swift
//  GithubAPI
//
//  Created by Kiran Kumar Sanka on 3/28/18.
//  Copyright © 2018 Kiran Kumar Sanka. All rights reserved.
//

import Foundation

class License: Codable {
    let key:String
    let name:String
    let spdxId:String?
    let url:String?
    
    enum CodingKeys: String, CodingKey {
        case key
        case name
        case spdxId = "spdx_id"
        case url = "created_at"
    }
}
