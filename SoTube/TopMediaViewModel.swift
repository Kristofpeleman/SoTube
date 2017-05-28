//
//  TopMediaViewModel.swift
//  SoTube
//
//  Created by VDAB Cursist on 17/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import Foundation

class TopMediaViewModel {

    let newReleasesURLAsString = "https://api.spotify.com/v1/browse/new-releases?country=US&offset=0&limit=50"
    
    func getNewReleasesWith(offset: Int) -> String {
        return "https://api.spotify.com/v1/browse/new-releases?country=US&offset=\(offset)&limit=50"
    }

}
