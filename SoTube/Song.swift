//
//  Song.swift
//  SoTube
//
//  Created by VDAB Cursist on 12/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import Foundation

// Created struct Song
struct Song {
    
    // Created variables
    let songTitle: String
    var cost: Int
    var duration: Int
    var favorite: Bool = false
    
    
    // Created constants
    let artistNames: [String]
    let spotify_ID: String?
    let previewURLAssString: String
    let imageURLAssString: String
    
    
    // Created calculated properties
    var artists: String {
        
        // Create a variable String containing the value of the first item in the array of "artistNames"
        var names = artistNames[0]
        
        // If there is more than 1 item in artistNames (more than 1 artist)
        if artistNames.count > 1 {
            
            // For each artist (excluding the first)
            for index in 1...artistNames.count - 1 {
                
                // Add the artist's name to "names" with a "&" between them
                names += " & \(artistNames[index])"
            }
            
        }
        
        // "artists"'s value is "names"
        return names
    }

    
    var fullSongURLAssString: String? {
        
        // if there is a spotify_ID
        if let id = self.spotify_ID {
            
            // "fullSongURLAssString"'s value is "spotify:track:" + the spotify_ID
            return "spotify:track:" + id
        }
        
        // Otherwise the value is "nil"
        return nil
    
    }


    var spotifyJSONFeed: String {
        return "https://api.spotify.com/v1/tracks/" + spotify_ID! + "?"
    }
    
    // Initialize the struct and give the variables and constants a value depending on the parameters
    init(songTitle: String, artistNames: [String], spotify_ID: String, duration: Int, imageURLAssString: String, previewURLAssString: String) {
        self.songTitle = songTitle
        self.artistNames = artistNames
        self.spotify_ID = spotify_ID
        self.previewURLAssString = previewURLAssString
        self.imageURLAssString = imageURLAssString
//        self.fullSongURLAssString = nil
        self.cost = 2
        self.duration = duration
    }
    
    init(favorite: Bool, songTitle: String, artistNames: [String], spotify_ID: String, duration: Int, imageURLAssString: String, previewURLAssString: String) {
        
        self.init(songTitle: songTitle, artistNames: artistNames, spotify_ID: spotify_ID, duration: duration, imageURLAssString: imageURLAssString, previewURLAssString: previewURLAssString)
        self.favorite = favorite
    }
    
}

