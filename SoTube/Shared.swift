//
//  Shared.swift
//  SoTube
//
//  Created by VDAB Cursist on 23/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import Foundation

// MARK: - Singleton

final class Shared {
    
    // Can't init is singleton
    private init() { }
    
    // MARK: Shared Instance
    
    static let current = Shared()
    
    // MARK: Local Variables
    
    var user : User?
    var songList: [Song]?
    var currentPositionInList: Int?
    var backGroundImage: String = "black_white_background"
    
    var player: SPTAudioStreamingController?
    
}
