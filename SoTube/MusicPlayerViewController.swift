//
//  MusicPlayerViewController.swift
//  SoTube
//
//  Created by VDAB Cursist on 12/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import AVFoundation
// Don't forget to import AVFoundation when working with sounds and videos

class MusicPlayerViewController: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
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
    
    // Variable because it's an optional
    //var currentUser: User?
    
    
    
    // MARK: - Outlets
    @IBOutlet weak var navigationSongTitle: UINavigationItem!
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var playOrPauseButton: UIButton! // Outlet because it's image can change
    
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var musicSlider: UISlider!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Calling function updateTitleSliderAndLabels (can't add comma's in function names)
        updateTitleSliderAndLabels()
        changeVolume(volumeSlider)
        
    }
    
    // Standard function
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // A timer repeating musicSliderUpdate every 0.1 second to update the musicSlider
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.musicSliderUpdate), userInfo: nil, repeats: true)
    }
    
    // Button to go to/load the previous song in our list
    @IBAction func previousSong(_ sender: UIButton) {
        // resets player and the positions of the sliders
        resetPlayerAndSliders()
        
        // Check if currentSongPositionInList and songList exist/aren't nil
        if currentSongPositionInList != nil && songList != nil {
            // Position can't go below 0, if it does go lower we must become the highest available number witin songList/our array
            if currentSongPositionInList == 0 {
                // .count starts counting at 1; an array starts at 0; hence ".count - 1"
                currentSongPositionInList = songList!.count - 1
            }
            else {
                // Become 1 position lower
                currentSongPositionInList! -= 1
            }
        }
        updateTitleSliderAndLabels()
    }
    
    
    // The play-button has to play or pause the song depending on the situation
    @IBAction func playSong(_ sender: UIButton) {
        
        
        // Check if player exists/isn't "nil"
        if let player = player {
            
            // Check if our player is playing right now
            if player.playbackState.isPlaying {
                // If it is playing, then it should stop
                
                pausePlayer()
                
                // and the pause-image of the button has to turn into a play
                playOrPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            }
                // If it isn't playing right now
            else {
                // Then it should start playing where we stopped
                continuePlaying()
                
                // and the play-image of the button has to turn into a pause
                playOrPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            }
        }
    }
    
    
    // When the musicSlider is touched
    @IBAction func alterMusicTime(_ sender: UISlider) {
        // update slider by itself
        updateSliderProgress()
    }
    
    
    func updateSliderProgress(){
        // Check if player exists/isn't "nil"
        if let player = player {
            // Remember the currentTime/position in our player
            let currentTime = TimeInterval(musicSlider.value)
            
            // stop playing
            pausePlayer()
            
            // change currentTime of player to  wherever you dragged the musicSlider
            playSound(startingAt: currentTime)
            
            continuePlaying()
            
            // change currentTimeLabel to match new currentTime
            currentTimeLabel.text = returnCurrentTimeInSong()
            
        }
    }
    
    // Function to update the musicSlider
    func musicSliderUpdate(){
        // Check if player exists/isn't "nil"
        /*if preview {
         musicSlider.maximumValue = 30
         }
         else {*/
        if let _ = player {
            if let _ = songList {
                musicSlider.maximumValue = Float(currentSong.duration)
                // }
                // change musicSlider's value/position on slider to the currentTime of player
                musicSlider.value = Float((player?.playbackState.position)!)
                
                // change currentTimeLabel to match new currentTime
                currentTimeLabel.text = returnCurrentTimeInSong()
                
                if musicSlider.value == musicSlider.maximumValue {
                    pausePlayer()
                    musicSlider.value = 0
                }
            }
        }
    }
    
    
    @IBAction func nextSong(_ sender: UIButton) {
        // Same as previousSong, except here we're going to the next songs.
        
        resetPlayerAndSliders()
        
        if currentSongPositionInList != nil && songList != nil {
            if currentSongPositionInList! == songList!.count - 1 {
                currentSongPositionInList = 0
            }
            else {
                currentSongPositionInList! += 1
            }
        }
        updateTitleSliderAndLabels()
        
    }
    
    
    // Bar button item resets sliders and goes back to whichever VC we came from before comming here
    @IBAction func back(_ sender: UIBarButtonItem) {
        resetPlayerAndSliders()
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - Volume Slider
    
    // Action for a UISlider to change the volume of our player
    @IBAction func changeVolume(_ sender: UISlider) {
        // First make sure player exists
        if let player = player {
            // The volume of player changes based on the value of volumeSlider (min. value: 0 (0%); max. value: 1 (100%))
            player.setVolume(SPTVolume(volumeSlider.value), callback: {(error) in
                if error != nil {
                    print("Changing volume")
                }
            })
        }
    }
    
    
    // Removes all contents of player and changes sliders' values to their standard
    func resetPlayerAndSliders(){
        pausePlayer()
        musicSlider.value = 0
    }
    
    
    
    
    
    // Returns the currentTime in the song as a string (meant for changing currentTimeLabel)
    func returnCurrentTimeInSong() -> String{
        // player needs to exist
        if let player = player {
            
            let currentTime = player.playbackState.position
            // If the currentTime < 10 --> put a "0" in the 10-value of seconds (eg.: currentTime = 5 --> 0:05; else it would have been 0:5)
            if Int(currentTime) < 10 {
                return "\(Int(currentTime / 60)):0\(Int(currentTime))"
            }
                // If currentTime > 10 --> just put currentTime without the "0" in the 10-value of seconds (eg.: currentTime = 15 --> 0:15)
            else {
                return "\(Int(currentTime / 60)):\(Int(currentTime) % 60)"
            }
        }
        // If player doesn't exist, just return "00:00"
        return "00:00"
    }
    
    
    // Returns the currentTime in the song as a string (meant for changing currentTimeLabel)
    func returnEndTimeInSong() -> String{
        // player needs to exist
        if let _ = player {
            
            let endTime = currentSong.duration
            // If the currentTime < 10 --> put a "0" in the 10-value of seconds (eg.: currentTime = 5 --> 0:05; else it would have been 0:5)
            if (endTime % 60) < 10 {
                return "\(endTime / 60):0\(endTime)"
            }
                // If currentTime > 10 --> just put currentTime without the "0" in the 10-value of seconds (eg.: currentTime = 15 --> 0:15)
            else {
                return "\(endTime / 60):\(endTime % 60)"
            }
        }
        // If player doesn't exist, just return "00:00"
        return "00:00"
    }
    
    
    
    
    
    // Function to create an player based on a URL
    func playSound(startingAt currentTime: TimeInterval) {
        player?.playSpotifyURI(currentSong.fullSongURLAssString, startingWith: 0, startingWithPosition: currentTime, callback: {(error) in
            if error != nil {
                print("Starting to play")
            }
        })
        playOrPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        
    }
    func initialize(authSession: SPTSession){
        pausePlayer()
        
        if self.player == nil {
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            try! self.player!.start(withClientId: auth?.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)
        }
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        playSound(startingAt: 0)
    }
    
    
    func pausePlayer(){
        if let player = player {
            player.setIsPlaying(false, callback: {(error) in
                if error != nil {
                    print("Pausing")
                }
            })
        }
    }
    
    func continuePlaying(){
        if let player = player {
            player.setIsPlaying(true, callback: {(error) in
                if error != nil {
                    print("Continue playing")
                }
            })
        }
    }
    
    
    // Function to update the Title, the Sliders and the Labels
    func updateTitleSliderAndLabels(){
        // Changes the title in our navigationBar to the songTitle
        initialize(authSession: session!)
        navigationSongTitle.title = currentSong.songTitle
        
        changeVolume(volumeSlider)
        currentTimeLabel.text = "00:00"
        endTimeLabel.text = returnEndTimeInSong()
        
        // Change the image of this button to a play-image
        playOrPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
    }
    
    
}
