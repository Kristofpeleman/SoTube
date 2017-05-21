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
    var userName: String
    var points: Int
    var fireBaseID: String
    
    var mySongs: [Song]?
    var wishList: [Song]?
    var shoppingCart: [Song]?
}
