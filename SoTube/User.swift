//
//  User.swift
//  SoTube
//
//  Created by VDAB Cursist on 19/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import Foundation
import Firebase

struct User {
    var emailAddress: String
    var userName: String
    var points: Int
    var fireBaseID: String
    
    var mySongs: [Song]?
    var wishList: [Song]?
    var shoppingCart: [Song]?
    
    init(fireBaseID: String, emailAddress: String, userName: String, points: Int) {
        self.fireBaseID = fireBaseID
        self.emailAddress = emailAddress
        self.userName = userName
        self.points = points
    }
    
    init(with snapshot: FIRDataSnapshot) {
        
        let snapshotValue = snapshot.value as! [String : Any?]
        
        let snapshotFirebaseID = snapshot.key
        
        let snapshotEmailAddress = snapshotValue["emailAddress"] as! String
        let snapshotUserName = snapshotValue["userName"] as! String
        let snapshotPoints = snapshotValue ["points"] as! Int
        
        self.init(fireBaseID: snapshotFirebaseID, emailAddress: snapshotEmailAddress, userName: snapshotUserName, points: snapshotPoints)

    }
    
}
