//
//  Song.swift
//  SoTube
//
//  Created by VDAB Cursist on 12/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import Foundation

struct Song {
    let songTitle: String
    let artistNames: [String]
    let spotify_ID: String?
    let previewURLAssString: String
    var fullSongURLAssString: String? {
        if let id = self.spotify_ID {
            return "spotify:track:" + id
        } else {return nil}
    }
    var cost: Int
    var favorite: Bool = false
    var spotifyJSONFeed: String {
        return "https://api.spotify.com/v1/tracks/" + spotify_ID! + "?"
    }
    
    init(songTitle: String, artistNames: [String], spotify_ID: String, previewURLAssString: String) {
        self.songTitle = songTitle
        self.artistNames = artistNames
        self.spotify_ID = spotify_ID
        self.previewURLAssString = previewURLAssString
//        self.fullSongURLAssString = nil
        self.cost = 2
    }
    
}
