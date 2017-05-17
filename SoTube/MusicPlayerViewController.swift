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
    
    // The piece that plays our sound
    var audioPlayer: AVAudioPlayer?

    
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
        
        // A timer repeating musicSliderUpdate every 0.1 second to update the musicSlider
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.musicSliderUpdate), userInfo: nil, repeats: true)
        
    }

    // Standard function
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // Button to go to/load the previous song in our list
    @IBAction func previousSong(_ sender: UIButton) {
        // resets audioPlayer and the positions of the sliders
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
        
        // Check if audioPlayer exists/isn't "nil"
        if let audioPlayer = audioPlayer {
            // Check if our audioPlayer is playing right now
            if audioPlayer.isPlaying {
                // If it is playing, then it should pause
                audioPlayer.pause()
                // and the pause-image of the button has to turn into a play
                playOrPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            }
            // If it isn't playing right now
            else {
                // Then it should start playing
                audioPlayer.play()
                // and the play-image of the button has to turn into a pause
                playOrPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            }
        }
        // If audioPlayer doesn't exist/is "nil" and songList does exist/isn't "nil"
        else if let _ = songList {
            // Call function to start playing sound based on our url that was saved as a String (We had fun with slightly altering the previewURL name...don't change it unless you want a lot of errors)
            playSound(withURL: URL(string: (currentSong.previewURLAssString))!)
            
            
            // currentTimeLabel needs to show the currentTime of the song/audioPlayer
            currentTimeLabel.text = returnCurrentTimeInSong()
            
            
            // If we're listening to the preview
            //if user.mySongs.contains{currentSong} {
                // The label says 30secs (duration of preview)
            //    endTimeLabel.text = "00:30"
           // }
                // If we aren't listening to a preview
           // else {
                // Change the endTimeLabel based on how long the song's duration is
                if Int(audioPlayer!.duration) < 10 {
                    endTimeLabel.text = "\(String(Int(audioPlayer!.duration/100))):0\(String(Int(audioPlayer!.duration)))"
                }
                else {
                    endTimeLabel.text = "\(String(Int(audioPlayer!.duration/100))):\(String(Int(audioPlayer!.duration)))"
                }
        //    }
            
            // Since audioPlayer is currently playing --> the play-image of the button has to turn into a pause
            playOrPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        }
    }
    
    
    // When the musicSlider is touched
    @IBAction func alterMusicTime(_ sender: UISlider) {
        // update slider by itself
       updateSliderProgress()
    }
    
    
    func updateSliderProgress(){
        // Check if audioPlayer exists/isn't "nil"
        if let audioPlayer = audioPlayer {
            // stop playing
            audioPlayer.stop()
            
            // change currentTime of audioPlayer to  wherever you dragged the musicSlider
            audioPlayer.currentTime = TimeInterval(musicSlider.value)
            
            // change currentTimeLabel to match new currentTime
            currentTimeLabel.text = returnCurrentTimeInSong()
            
            // prepare to start playing again (might be redundant code)
            audioPlayer.prepareToPlay()
            
            // continue playing the song (could be left out, but won't immediatly start playing when changing slider)
            audioPlayer.play()
            
            
        }
    }
    
    // Function to update the musicSlider
    func musicSliderUpdate(){
        // Check if audioPlayer exists/isn't "nil"
        if let audioPlayer = audioPlayer {
            /*if preview {
                musicSlider.maximumValue = 30
            }
            else {*/
                musicSlider.maximumValue = Float(audioPlayer.duration)
           // }
            // change musicSlider's value/position on slider to the currentTime of audioPlayer
            musicSlider.value = Float(audioPlayer.currentTime)
            
            // change currentTimeLabel to match new currentTime
            currentTimeLabel.text = returnCurrentTimeInSong()
            
            if musicSlider.value == musicSlider.maximumValue {
                self.audioPlayer = nil
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
    
    // Action for a UISlider to change the volume of our audioPlayer
    @IBAction func changeVolume(_ sender: UISlider) {
        // First make sure audioPlayer exists
        if let audioPlayer = audioPlayer {
            // The volume of audioPlayer changes based on the value of volumeSlider (min. value: 0 (0%); max. value: 1 (100%))
            audioPlayer.volume = volumeSlider.value
        }
    }
    
    
    // Removes all contents of audioPlayer and changes sliders' values to their standard
    func resetPlayerAndSliders(){
        audioPlayer = nil
        musicSlider.value = 0
        volumeSlider.value = 0.5
    }
    
    
    
    
    
    // Returns the currentTime in the song as a string (meant for changing currentTimeLabel)
    func returnCurrentTimeInSong() -> String{
        // audioPlayer needs to exist
        if let audioPlayer = audioPlayer {
            // If the currentTime < 10 --> put a "0" in the 10-value of seconds (eg.: currentTime = 5 --> 0:05; else it would have been 0:5)
            if Int(audioPlayer.currentTime) < 10 {
                return "\(String(Int(audioPlayer.currentTime / 100))):0\(String(Int(audioPlayer.currentTime)))"
            }
            // If currentTime > 10 --> just put currentTime without the "0" in the 10-value of seconds (eg.: currentTime = 15 --> 0:15)
            else {
                return "\(String(Int(audioPlayer.currentTime / 100))):\(String(Int(audioPlayer.currentTime)))"
            }
        }
        // If audioPlayer doesn't exist, just return "00:00"
        return "00:00"
    }
    
    
    
    
    
    
    // Function to create an audioPlayer based on a URL
    func playSound(withURL url : URL) {
        
        // Using "do" so we can use a "try"
        do {
            // Try to give an AVAudioPlayer containing the parameter as URL to audioPlayer
            try audioPlayer = AVAudioPlayer.init(data: Data(contentsOf: url), fileTypeHint: "mp3")
        }
        // If the "try" in "do" fails, we print the failure
        catch {
            print("assignment of audioplayer failed")
        }
        // Start playing our AudioPlayer
        audioPlayer?.play()
    }
    
    
    
    // Function to update the Title, the Sliders and the Labels
    func updateTitleSliderAndLabels(){
        // Changes the title in our navigationBar to the songTitle
        navigationSongTitle.title = currentSong.songTitle
        
        currentTimeLabel.text = "00:00"
        endTimeLabel.text = "00:00"
        
        // Change the image of this button to a play-image
        playOrPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
