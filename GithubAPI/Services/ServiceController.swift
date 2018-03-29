//
//  ServiceController.swift
//  GithubAPI
//
//  Created by Kiran Kumar Sanka on 3/28/18.
//  Copyright © 2018 Kiran Kumar Sanka. All rights reserved.
//

import Foundation
import UIKit

enum APIError : Error {
    
    case gitHubAPI(String)
    
    func value() -> String {
        switch self {
        case let .gitHubAPI(value):
            return value
        }
    }
}

class ServiceController {
    static let sharedInstance = ServiceController()
    let sharedSession = URLSession.shared
    var serviceBaseURL:String = "https://api.github.com/users/"

    func getUsers(byName name:String, perPage:Int = 10, page:Int = 0, completion:@escaping (_ users:[User]?, _ error:Error?)->Void) {
        guard let url = URL(string: serviceBaseURL+name+"/repos?"+"page=\(page)"+"&"+"per_page=\(perPage)") else {
            return
        }
        
        print("Loading page..\(page)")
        
        //TODO:HandleError
        let task = sharedSession.dataTask(with: url) { (data, response, err) in
            print("returned page..\(page)")
            guard err == nil else {
                completion(nil, err)
                return
            }
            if let userData = data {
                do {
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.dateDecodingStrategy = .iso8601
                    let users = try jsonDecoder.decode([User].self, from: userData)
                    completion(users,nil)
                } catch  {
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    //Handles Github API Error
    func handleError(dict:NSDictionary) -> Error? {
        var error:Error? = nil
        
        guard let code = dict["cod"] as? String else {
            return error
        }
        if code != "200" {
            var errorMessage = "Something went wrong please try later"
            if let message = dict["message"] as? String {
                errorMessage = message
            }
            error = APIError.gitHubAPI(errorMessage)
        }
        return error
    }
    
}
