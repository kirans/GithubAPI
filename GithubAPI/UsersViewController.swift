//
//  UsersViewController.swift
//  GithubAPI
//
//  Created by Kiran Kumar Sanka on 3/28/18.
//  Copyright © 2018 Kiran Kumar Sanka. All rights reserved.
//

import UIKit

let cellIdentifier = "userCellIdentifier"
let loadingCellIdentifier = "loadingCellIdentifier"

class UsersViewController: UIViewController {
    enum LayoutType:Int {
        case list = 100
        case grid = 200
    }
    
    @IBOutlet weak var usersCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var users:[User] = []
    var pageCoordinator:PageServiceCoordinator = PageServiceCoordinator()
    var layoutType:LayoutType = .list
    
    @IBAction func changeLayout(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        
        switch layoutType {
        case .list:
            if button.tag == LayoutType.grid.rawValue {
                self.layoutType = .grid
                self.usersCollectionView.collectionViewLayout.invalidateLayout()
            }
        case .grid:
            if button.tag == LayoutType.list.rawValue {
                self.layoutType = .list
                self.usersCollectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    func setup() {
        User.dateFormatter.dateStyle = .short
        self.usersCollectionView.register(UINib.init(nibName:"UserCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        self.pageCoordinator = PageServiceCoordinator { (perPage, page, searchString, completion) in
            guard let perPage = perPage, let page = page, let searchString = searchString else {
                return
            }
            
            ServiceController.sharedInstance.getUsers(byName:searchString, perPage:perPage, page:page) { (pageUsers, error) in
                guard let users = pageUsers else {
                    return
                }
                DispatchQueue.main.async {
                    self.users.append(contentsOf: users)
                    self.usersCollectionView.reloadData()
                    completion(users.count)
                }
            }
        }

    }
    
    func refresh() {
        self.users = []
        self.pageCoordinator.refresh()
        self.usersCollectionView.reloadData()
        if let searchTerm = self.searchBar.text {
            self.pageCoordinator.searchTerm = searchTerm
        }
        self.pageCoordinator.fetch {
        }
    }
    
    func shouldShowLoadingIndicator() -> Bool {
        var shouldShowIndicator = self.pageCoordinator.fetching || self.pageCoordinator.more
        if let searchBarTextCount = self.searchBar.text?.count, searchBarTextCount == 0 {
            shouldShowIndicator = false
        }
        return shouldShowIndicator
    }
    
    func loadUsers() {
        guard let searchString = searchBar.text, searchString.count > 0, !self.pageCoordinator.fetching, self.pageCoordinator.more  else {
            return
        }
        self.pageCoordinator.fetching = true
        ServiceController.sharedInstance.getUsers(byName:searchString, page:self.users.count/10 + 1) { (pageUsers, error) in
            if let users = pageUsers {
                DispatchQueue.main.async {
                    //TODO:Paging Logic should be moved to pageCordinator
                    self.pageCoordinator.fetching = false
                    if users.count < self.pageCoordinator.perPage {
                        self.pageCoordinator.more = false
                        self.pageCoordinator.page = self.pageCoordinator.page + 1
                    }
                    self.users.append(contentsOf: users)
                    self.usersCollectionView.reloadData()
                }
            }
        }
    }
    
    //TODO:Should calculate height of cell instead of using static height
    func cellLayoutfittingSize(at indexPath:IndexPath) -> CGSize {
        let size = self.view.bounds.size
        let length = min(size.width, size.height)
        let width = (length)
        let height:CGFloat = 180

        if indexPath.row == self.users.count {
            return CGSize(width: width, height: 50)
        }
        
        switch layoutType {
        case .list:
            return CGSize(width: self.view.frame.width, height:height)
        case .grid:
            return CGSize(width: self.view.frame.width/2, height:height)
        }
    }
    
    func configure(cell:UserCollectionViewCell, at indexPath:IndexPath) {
        let user = self.users[indexPath.row]
        cell.name.text = user.name
        cell.userDescription.text = user.description
        if let created = user.created {
            cell.created.text = User.dateFormatter.string(from: created)
        }
        cell.layer.borderColor = UIColor.blue.cgColor
        cell.layer.borderWidth = 1.0
    }
}

// MARK:- UICollectionViewDataSource, UICollectionViewDelegate
extension UsersViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.shouldShowLoadingIndicator() ? self.users.count + 1 : self.users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == self.users.count {
             let cell = collectionView.dequeueReusableCell(withReuseIdentifier:loadingCellIdentifier, for: indexPath)
            if let actiVityIndicator = cell.viewWithTag(100) as? UIActivityIndicatorView {
                actiVityIndicator.startAnimating()
            }
            return cell
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? UserCollectionViewCell else {
            return UICollectionViewCell()
        }
        self.configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

// MARK:- UICollectionViewDelegateFlowLayout
extension UsersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = self.cellLayoutfittingSize(at: IndexPath(row: 0, section: 0))
        return size
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK:- UIScrollViewDelegate

extension UsersViewController:UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.loadMore()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.loadMore()
    }
    
    func loadMore() {
        let currentOffset = self.usersCollectionView.contentOffset.y
        let maximumOffset = self.usersCollectionView.contentSize.height - self.usersCollectionView.frame.size.height
        
        if maximumOffset - currentOffset <= 150 {
            self.pageCoordinator.fetch {
            }
        }
    }
}

// MARK:- UISearchBarDelegate
extension UsersViewController:UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.refresh()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}
