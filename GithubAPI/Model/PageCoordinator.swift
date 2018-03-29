//
//  PageDataSource.swift
//  GithubAPI
//
//  Created by Kiran Kumar Sanka on 3/28/18.
//  Copyright © 2018 Kiran Kumar Sanka. All rights reserved.
//

import Foundation

typealias ServiceRequestClosure = (_ limit: Int?, _ page: Int?) -> Void

class PageCoordinator {
    var more = true
    var fetching = false
    var page = 0
    
    var perPage: Int = 10

    var available: Bool {
        return more && !fetching
    }
    
    var requestClosure:ServiceRequestClosure?
    
    func fetch(completion:()->Void) {
        guard let closure = requestClosure, available else {
            return
        }
        fetching = true
        //TODO:Paging logic should be moved here
    }
    
    func refresh() {
        self.more = true
        self.fetching = false
        self.page = 0
    }
}
