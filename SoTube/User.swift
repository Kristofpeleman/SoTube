//
//  User.swift
//  SoTube
//
//  Created by VDAB Cursist on 19/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import Foundation

struct User {
    var emailAddress: String
    var username: String
    var points: Int
    
    var mySongs: [Song]?
    var wishList: [Song]?
    var shoppingCart: [Song]?
}
