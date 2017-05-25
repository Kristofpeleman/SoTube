//
//  User.swift
//  SoTube
//
//  Created by VDAB Cursist on 19/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import Foundation
import Firebase

// Don't forget to import Firebase !!

// Created class "User"
class User {
    // Created variables
    var emailAddress: String
    var userName: String
    var points: Int
    var fireBaseID: String
    
    var mySongs: [Song]?
    var wishList: [Song]?
    var shoppingCart: [Song]?
    
    // Initialization will require "fireBaseID", "emailAddress", "userName" and "points"
    init(fireBaseID: String, emailAddress: String, userName: String, points: Int) {
        self.fireBaseID = fireBaseID
        self.emailAddress = emailAddress
        self.userName = userName
        self.points = points
    }
    
    // Convenience initialization that requires a "FIRDataSnapShot" and calls the normal initialization inside itself
    convenience init(with snapshot: FIRDataSnapshot) {
        // Local constant "snapshotValue" containing "snapshot.value" as a Dictionary of "[String: Any?]"
        let snapshotValue = snapshot.value as! [String : Any?]
        
        // Local constant "snapShotFirebaseID" with value "snapshot.key"
        let snapshotFirebaseID = snapshot.key
        
        // Local constants and their values being set
        let snapshotEmailAddress = snapshotValue["emailAddress"] as! String
        let snapshotUserName = snapshotValue["userName"] as! String
        let snapshotPoints = snapshotValue ["points"] as! Int
        
        // Calling normal initialization with our snapshot constants as parameters
        self.init(fireBaseID: snapshotFirebaseID, emailAddress: snapshotEmailAddress, userName: snapshotUserName, points: snapshotPoints)
        
        // If "snapshotValue["shoppingCart"] as? [String : Any]" exists/isn't nil
        if let snapshotShoppingCart = snapshotValue["shoppingCart"] as? [String : Any] {

            // For each item in the shoppingCart (each item is a tuple, but we only need it's value (value could still be a seperate array or another tuple))
            for (_ , value) in snapshotShoppingCart {
                // Local constant "dictionary" containing "value as! Dictionary<String, AnyObject>"
                let dictionary = value as! Dictionary<String, AnyObject>
                
                // Local constant "song" containing a value of class "Song" with initialization parameters being parts of our tuple's values
                let song = Song(songTitle: dictionary["songTitle"] as! String, artistNames: [dictionary["artists"] as! String], spotify_ID: dictionary["spotify_ID"] as! String, duration: dictionary["duration"] as! Int, imageURLAssString: dictionary["imageURL"] as! String, previewURLAssString: dictionary["previewURL"] as! String)
                // Call function "addToShoppingCart" with parameter our local "song"
                addToShoppingCart(song)
            }
        }
        
        // If "snapshotValue["mySongs"] as? [String : Any]" exists/isn't nil
        if let snapshotMySongs = snapshotValue["mySongs"] as? [String : Any] {
            
            print(snapshotMySongs)
            
            // for each item/tuple in snapshotMySongs
            for (_ , value) in snapshotMySongs {
                // Create a constant of the value of the tuple (not including the key) and put it in the constant as a dictionary of [String : Any]
                let dictionary = value as! Dictionary<String, AnyObject>
                

                // Create a constant of type "Song" where it's parameters for the init are the values of the dictionary we just created above
                // NOTE: Values in a dictionary are called by using their key (in this case a String)
                let song = Song(favorite: dictionary["favorite"] as! Bool, songTitle: dictionary["songTitle"] as! String, artistNames: [dictionary["artists"] as! String], spotify_ID: dictionary["spotify_ID"] as! String, duration: dictionary["duration"] as! Int, imageURLAssString: dictionary["imageURL"] as! String, previewURLAssString: dictionary["previewURL"] as! String)

                
                // Call function to add newly created song to mySongs
                addToMySongs(song)
            }
        }
        
        // If "snapshotValue["wishList"] as? [String : Any]" exists/isn't nil
        if let snapshotWishList = snapshotValue["wishList"] as? [String : Any] {
            
            // Same "for"-loop as above, except for "wishList" instead of "mySongs"
            for (_ , value) in snapshotWishList {
                
                let dictionary = value as! Dictionary<String, AnyObject>
                
                let song = Song(songTitle: dictionary["songTitle"] as! String, artistNames: [dictionary["artists"] as! String], spotify_ID: dictionary["spotify_ID"] as! String, duration: dictionary["duration"] as! Int, imageURLAssString: dictionary["imageURL"] as! String, previewURLAssString: dictionary["previewURL"] as! String)
                
                addToWishList(song)
            }
        }
        

    }
    
    // Function to add an item of class "Song" to our shoppingCart
    func addToShoppingCart(_ song: Song) {
        
        // If shoppingCart exists/isn't nil
        if let _ = self.shoppingCart {
            
            // Add song to the array
            self.shoppingCart?.append(song)
        }
            
        // If shoppingCart has value nil
        else {
            
            // Give shoppingCart [song] as a value
            self.shoppingCart = [song]
        }
    }
    
    // Function to add an item of class "Song" to our wishList
    func addToWishList(_ song: Song) {
        
        // Same as with shoppingCart, except it is for wishList
        if let _ = self.wishList {
            self.wishList?.append(song)
        }
        else {
            self.wishList = [song]
        }
    }
    
    // Function to add an item of class "Song" to our songs ("mySongs")
    func addToMySongs(_ song: Song) {
        
        // Same as with shoppingCart, except it is for mySongs
        if let _ = self.mySongs {
            self.mySongs?.append(song)
        }
        else {
            self.mySongs = [song]
        }
    }
    
    // Function to add an array of "Song" objects to our songs ("mySongs")
    func addToMySongs(_ songs: [Song]) {
        
        // Same as with mySongs, except parameter isn't of type "Song", but of type "[Song]" (an array containing items of type "Song")
        if let _ = self.mySongs {
            
            // When adding a array to another array, we can't use ".append", so we use "+="
            self.mySongs! += songs
        }
        else {
            self.mySongs = songs
        }
    }
}
