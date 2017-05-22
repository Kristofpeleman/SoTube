//
//  User.swift
//  SoTube
//
//  Created by VDAB Cursist on 19/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import Foundation
import Firebase

class User {
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
    
    convenience init(with snapshot: FIRDataSnapshot) {
        
        let snapshotValue = snapshot.value as! [String : Any?]
        
        let snapshotFirebaseID = snapshot.key
        
        let snapshotEmailAddress = snapshotValue["emailAddress"] as! String
        let snapshotUserName = snapshotValue["userName"] as! String
        let snapshotPoints = snapshotValue ["points"] as! Int
        
        self.init(fireBaseID: snapshotFirebaseID, emailAddress: snapshotEmailAddress, userName: snapshotUserName, points: snapshotPoints)
        
        if let snapshotShoppingCart = snapshotValue["shoppingCart"] as? [String : Any] {
            print(snapshotShoppingCart)
            for (_ , value) in snapshotShoppingCart {
                let dictionary = value as! Dictionary<String, AnyObject>
                let song = Song(songTitle: dictionary["songTitle"] as! String, artistNames: [dictionary["artists"] as! String], spotify_ID: dictionary["spotify_ID"] as! String, duration: dictionary["duration"] as! Int, imageURLAssString: dictionary["imageURL"] as! String, previewURLAssString: dictionary["previewURL"] as! String)
                addToShoppingCart(song)
            }
        }
        
        print(self.shoppingCart ?? "SHOPPING CART EMPTY")

    }
    
    func addToShoppingCart(_ song: Song) {
        if let _ = self.shoppingCart {
            self.shoppingCart?.append(song)
        } else {self.shoppingCart = [song]}
    }
    
    func addToWishList(_ song: Song) {
        if let _ = self.wishList {
            self.wishList?.append(song)
        } else {self.wishList = [song]}
    }
    
    func addToMySongs(_ song: Song) {
        if let _ = self.mySongs {
            self.mySongs?.append(song)
        } else {self.mySongs = [song]}
    }
    
}
