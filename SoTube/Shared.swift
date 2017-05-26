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
    
    // MARK: Local Variable
    
    var user : User?
    var songList: [Song]?
    var currentPositionInList: Int?
}
