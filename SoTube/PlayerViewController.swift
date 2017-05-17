//
//  PlayerViewController.swift
//  SoTube
//
//  Created by VDAB Cursist on 17/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
    // MARK: - Constants and variables
    
    var auth: SPTAuth?
    var session: SPTSession?
    var player: SPTAudioStreamingController?
    
    
    // The current position of the song inside songList (remember: we're comming from a VC in the SongsViewControllers folder/group which gave this info)
    var currentSongPositionInList: Int?
    
    // The current list of songs we need to navigate in (could be: All, Filtered, My Songs, Favorites or Wishlist)(and obeys the previous VC's sort(by:) logic)
    var songList: [Song]?
    
    // Calculated property to define the current song form the info we got from the previous VC (makes it easier to call later on in code)
    var currentSong: Song {
        return songList![currentSongPositionInList!]
    }
    
    
    // MARK: - UIViewController Functions

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK - IBActions
    
    
    @IBAction func play(_ sender: UIButton) {
        initializePlayer(authSession: session!)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - Homemade Functions
    
    func initializePlayer(authSession:SPTSession){
        
        if self.player == nil {
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            try! player!.start(withClientId: auth?.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)
        }
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
        print("logged in")
        self.player?.playSpotifyURI(currentSong.fullSongURLAssString!, startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if (error != nil) {
                print("playing!")
            }
        })
        
        
    }

}
