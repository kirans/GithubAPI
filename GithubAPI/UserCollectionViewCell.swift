//
//  UserCollectionViewCell.swift
//  GithubAPI
//
//  Created by Kiran Kumar Sanka on 3/28/18.
//  Copyright © 2018 Kiran Kumar Sanka. All rights reserved.
//

import Foundation
import UIKit

class UserCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var userDescription:UILabel!
    @IBOutlet weak var created:UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.name.text = nil
        self.userDescription.text = nil
        self.created.text = nil
    }
}
