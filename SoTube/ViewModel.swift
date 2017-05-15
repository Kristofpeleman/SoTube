//
//  ViewModel.swift
//  SoTube
//
//  Created by VDAB Cursist on 12/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import Foundation

class ViewModel {
    let spotifyIDs: [String]  = [
        "1zHlj4dQ8ZAtrayhuDDmkY",
        "7ouMYWpwJ422jRcDASZB7P",
//        "4VqPOruhp5EdPBeR92t6lQ",
        "2takcwOaAZWiXQijPHIx7B",
//        "0c4IEciLCDdXEhhKxj4ThA",
        "3skn2lauGk7Dx6bVIt5DVj",
        "0COqiPhxzoWICwFCS4eZcp",
        "3UygY7qW2cvG9Llkay6i1i",
        "3PYdxIDuBIuJSDGwfptFx4",
//        "60a0Rd6pjrkxjPbaKzXjfq",
        "7dyluIqv7QYVTXXZiMWPHW"
    ]
    
    var feeds: [String] {
        return spotifyIDs.map{"https://api.spotify.com/v1/tracks/" + $0 + "?"}
    }
}
