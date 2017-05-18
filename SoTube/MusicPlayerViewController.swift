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
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var navigationSongTitle: UINavigationItem!
    @IBOutlet weak var previousAlbumImageView: UIImageView!
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var nextAlbumImageView: UIImageView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var playOrPauseButton: UIButton! // Outlet because it's image can change
    
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var musicSlider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Calling function updateTitleSliderAndLabels (can't add comma's in function names)
        updateOutlets()
        changeVolume(volumeSlider)
        
    }
    
    // Standard function
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // A timer repeating musicSliderUpdate every few seconds (or less depending on timeInterval) to update the musicSlider
        _ = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(self.musicSliderUpdate), userInfo: nil, repeats: true)
    }
    
    
    
    // When the musicSlider is touched
    @IBAction func alterMusicTime(_ sender: UISlider) {
        // update slider by itself
        
        musicSlider.addTarget(nil, action: #selector(updateSliderProgress), for: .touchUpInside)
        musicSlider.addTarget(nil, action: #selector(updateSliderProgress), for: .touchUpOutside)
        musicSlider.actions(forTarget: nil, forControlEvent: .touchUpInside)
        musicSlider.actions(forTarget: nil, forControlEvent: .touchUpOutside)
    }
    
    
    func updateSliderProgress(){
        // Check if player exists/isn't "nil"
    
        if let _ = player {
            // Stop playing
            pausePlayer()
            
            
            let currentTime = TimeInterval(musicSlider.value)
            
            updateTimeLabels()
            
            // change currentTime of player to  wherever you dragged the musicSlider
            playSound(startingAt: currentTime)            
            continuePlaying()
            
        }
        
    }
    
    
    
    
    
    
    // Function to update the musicSlider
    func musicSliderUpdate(){
        if !musicSlider.isTouchInside {
        // If player exists and songList exists (a "," is the same as "&&")
        if let _ = player, let _ = songList {
            
            // MaximumValue has to be a Float, duration is a Int
            musicSlider.maximumValue = Float(currentSong.duration)
            
            // change musicSlider's value/position on slider to the currentTime of player
            musicSlider.setValue(Float(player!.playbackState.position), animated: true)
            
            // Out of laziness: call the function that updates both timeLabels
            updateTimeLabels()
            }
        }
    }
    
    
    @IBAction func swipeToPreviousSong(_ sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            goToPreviousSong()
        }
    }
    
    
    // Functions speak for themselves
    @IBAction func previousSong(_ sender: UIButton) {
        goToPreviousSong()
    }
    
    // Button to go to/load the previous song in our list
    func goToPreviousSong(){
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
        updateOutlets()
        playSound(startingAt: 0)
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

    @IBAction func swipeToNextSong(_ sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            goToNextSong()
        }
    }
    
    // Functions speak for themselves
    @IBAction func nextSong(_ sender: UIButton) {
        goToNextSong()
    }
    
    // Same as previousSong, except here we're going to the next songs.
    func goToNextSong(){
        resetPlayerAndSliders()
        
        if currentSongPositionInList != nil && songList != nil {
            if currentSongPositionInList! == songList!.count - 1 {
                currentSongPositionInList = 0
            }
            else {
                currentSongPositionInList! += 1
            }
        }
        updateOutlets()
        playSound(startingAt: 0)
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
    
    
    
    
    // Function to create an player based on a URL
    func playSound(startingAt currentTime: TimeInterval) {
        player?.playSpotifyURI(currentSong.fullSongURLAssString, startingWith: 0, startingWithPosition: currentTime, callback: {(error) in
            if error != nil {
                print("Starting to play")
            }
        })
        // Since it start playing instantly -> the button's image need to become a pause
        playOrPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
    }
    
    
    // Function to initialize the session for our player
    func initialize(authSession: SPTSession){
        // If the player exists we will want to pause it (just in case)
        pausePlayer()
        // If player doesn't exist/is nil
        if self.player == nil {
            // Give player the value of an SPTAudioStreamingController, more specificly it's sharedInstance (so we don't need to type "sharedInstance" every time we want to use it)
            self.player = SPTAudioStreamingController.sharedInstance()
            
            // Set player's delegate and playbackDelegate
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            
            // If the player isn't logged in yet
            if !player!.loggedIn {
                // A try that can't fail, if it could fail our app would be useless
                // Start the player with clientID
                try! self.player!.start(withClientId: auth?.clientID)
                
                // Log in with the access token (token lasts 1 hour) (this will also automaticly activate audioStreamingDidLogin)
                self.player!.login(withAccessToken: authSession.accessToken)
            }
            // If he is already logged in
            else {
                audioStreamingDidLogin(player)
            }
        }
    }
    
    // Function activates when login was succesful
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        // Call the function to play our sound; "startingAt" needs the position in the song where we want to start (position defined in seconds); since we want to start at the beginning of the song, we use 0
        playSound(startingAt: 0)
    }
    
    
    // Function to pause the song
    func pausePlayer(){
        if let player = player {
            player.setIsPlaying(false, callback: {(error) in
                if error != nil {
                    print("Pausing")
                }
            })
        }
    }
    
    // Function to continue playing the song
    func continuePlaying(){
        if let player = player {
            player.setIsPlaying(true, callback: {(error) in
                if error != nil {
                    print("Continue playing")
                }
            })
        }
    }
    
    // Function speaks for itself; WARNING: DO NOT CALL AT VIEWDIDLOAD -> At viewDidLoad we don't have a player.playbackState.position yet, so we will crash
    func updateTimeLabels(){
        // Call our function to change the value in the label
        currentTimeLabel.text = returnCurrentTimeInSong()
        
        // Call our function to change the value in the label
        endTimeLabel.text = returnEndTimeInSong()
    }
    
    
    // Removes all contents of player and changes sliders' values to their standard
    func resetPlayerAndSliders(){
        pausePlayer()
        musicSlider.value = 0
    }
    
    /*
    func updateImageViews(){
        if let songList = songList, let currentSongPositionInList = currentSongPositionInList {
            if currentSongPositionInList == 0 {
                previousAlbumImageView.image = songList.last.image
            }
            else {
                previousAlbumImageView.image = songList[currentSongPositionInList - 1].image
            }
            albumImageView.image = currentSong.image
            
            if currentSongPositionInList == songList.count - 1 {
                nextAlbumImageView.image = songList.first.image
            }
            else {
                nextAlbumImageView.image = songList[currentSongPositionInList + 1].image
            }
        }
    }
    */
    // Function to update the Title, the Sliders and the Labels
    func updateOutlets(){
        // Changes the title in our navigationBar to the songTitle
        initialize(authSession: session!)
        navigationSongTitle.title = currentSong.songTitle
        
   //     updateImageViews()
        
        // Volume needs to adjust to where the volumeSlider currently is
        changeVolume(volumeSlider)
        
        // We don't have a currentTime yet, but since we start at 0... (also the reason why we don't call updateTimeLabels())
        currentTimeLabel.text = "0:00"
        
        // Call our function to change the value in the label
        endTimeLabel.text = returnEndTimeInSong()
        
        
        // Change the image of this button to a play-image
        playOrPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        
        //Sets the central UIImageView to an album image of the currently playing song
        albumImageView.image = UIImage(data: try! Data(contentsOf: URL(string: currentSong.imageURLAssString)!))

        //Set the background image (blurred)
        background.image = albumImageView.image
        
        //Sets the album image of the previous song in the context
        if currentSongPositionInList == 0 {
            previousAlbumImageView.image = UIImage(data: try! Data(contentsOf: URL(string: songList![13].imageURLAssString)!))
        } else {
            previousAlbumImageView.image = UIImage(data: try! Data(contentsOf: URL(string: songList![currentSongPositionInList! - 1].imageURLAssString)!))
        }
        
        //Sets the album image of the next song in the context
        if currentSongPositionInList == songList!.count - 1 {
            nextAlbumImageView.image = UIImage(data: try! Data(contentsOf: URL(string: songList![0].imageURLAssString)!))
        } else {
            nextAlbumImageView.image = UIImage(data: try! Data(contentsOf: URL(string: songList![currentSongPositionInList! + 1].imageURLAssString)!))
        }
        
    }
    
    
    
    // Returns the currentTime in the song as a string (meant for changing currentTimeLabel)
    func returnCurrentTimeInSong() -> String{
        // player needs to exist
        if let player = player {
            
            let currentTime = player.playbackState.position
            // If the currentTime < 10 --> put a "0" in the 10-value of seconds (eg.: currentTime = 5 --> 0:05; else it would have been 0:5)
            if Int(currentTime) % 60 < 10 {
                return "\(Int(currentTime / 60)):0\(Int(currentTime) % 60)"
            }
                // If currentTime > 10 --> just put currentTime without the "0" in the 10-value of seconds (eg.: currentTime = 15 --> 0:15)
            else {
                return "\(Int(currentTime / 60)):\(Int(currentTime) % 60)"
            }
        }
        // If player doesn't exist, just return "00:00"
        return "0:00"
    }
    
    
    // Returns the endTime in the song as a string (meant for changing endTimeLabel)
    func returnEndTimeInSong() -> String{
        // player needs to exist
        if let _ = player {
            
            // The duration of our song that is going to play is given inside the class Song
            let endTime = currentSong.duration
            
            // If the currentTime < 10 --> put a "0" in the 10-value of seconds (eg.: currentTime = 5 --> 0:05; else it would have been 0:5)
            if (endTime % 60) < 10 {
                return "\(endTime / 60):0\(endTime % 60)"
            }
                // If currentTime > 10 --> just put currentTime without the "0" in the 10-value of seconds (eg.: currentTime = 15 --> 0:15)
            else {
                return "\(endTime / 60):\(endTime % 60)"
            }
        }
        // If player doesn't exist, just return "00:00"
        return "0:00"
    }
    
    
    

}
