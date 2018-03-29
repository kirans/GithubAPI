//
//  PageDataSource.swift
//  GithubAPI
//
//  Created by Kiran Kumar Sanka on 3/28/18.
//  Copyright © 2018 Kiran Kumar Sanka. All rights reserved.
//

import Foundation

typealias ServiceRequestClosure = (_ perPage: Int?, _ page: Int?, _ searchTerm:String?, _ completion:@escaping ((_ resultCount:Int) -> Void)) -> Void

class PageServiceCoordinator {
    var more = true
    var fetching = false
    var page = 0
    var searchTerm = ""
    
    var perPage: Int = 10

    var available: Bool {
        return more && !fetching
    }
    
    var requestClosure:ServiceRequestClosure?
    
    convenience init(closure:@escaping ServiceRequestClosure) {
        self.init()
        requestClosure = closure
    }
    
    func fetch(completion:@escaping ()->Void) {
        guard let closure = requestClosure, available else {
            return
        }
        fetching = true
        
        closure(self.perPage, page, searchTerm) {[weak self] (resultCount) in
            guard let coordinator = self else { return }
            coordinator.fetching = false
            if resultCount < coordinator.perPage {
                coordinator.more = false
            } else {
                coordinator.page = coordinator.page + 1
            }
            completion()
        }
    }
    
    func refresh() {
        self.more = true
        self.fetching = false
        self.page = 0
    }
}



