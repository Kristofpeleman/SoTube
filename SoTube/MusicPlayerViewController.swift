//
//  MusicPlayerViewController.swift
//  SoTube
//
//  Created by VDAB Cursist on 12/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import AVFoundation

class MusicPlayerViewController: UIViewController {
    
    
    //var currentSong: Song?
    var currentSongPositionInList: Int?
    var songList: [Song]?
    var currentSong: Song {
        return songList![currentSongPositionInList!]
    }
    var audioPlayer: AVAudioPlayer?
    var displayLink: CADisplayLink?

    @IBOutlet weak var navigationSongTitel: UINavigationItem!
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var playOrPauseButton: UIButton!
    
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var musicSlider: UISlider!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                // Do any additional setup after loading the view.
        //navigationSongTitel.title = currentSong?.songTitle
        updateTitleSliderAndLabels()
        
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.musicSliderUpdate), userInfo: nil, repeats: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    @IBAction func previousSong(_ sender: UIButton) {
        resetPlayerAndSliders()
        
        if currentSongPositionInList != nil && songList != nil {
            if currentSongPositionInList == 0 {
                currentSongPositionInList = songList!.count - 1
            }
            else {
                currentSongPositionInList! -= 1
            }
        }
        
        updateTitleSliderAndLabels()
    }
    
    
    
    @IBAction func playSong(_ sender: UIButton) {
        
        if let audioPlayer = audioPlayer {
            if audioPlayer.isPlaying {
                audioPlayer.pause()
                playOrPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
                
            }
            else {
                audioPlayer.play()
                playOrPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            
            }
        }
        else if let _ = songList {
            playSound(withURL: URL(string: (currentSong.previewURLAssString))!)
            musicSlider.maximumValue = Float(audioPlayer!.duration)
            
            currentTimeLabel.text = returnCurrentTimeInSong()
            
            if Int(audioPlayer!.duration) < 10 {
                endTimeLabel.text = "\(String(Int(audioPlayer!.duration/100))):0\(String(Int(audioPlayer!.duration)))"
            }
            else {
                endTimeLabel.text = "\(String(Int(audioPlayer!.duration/100))):\(String(Int(audioPlayer!.duration)))"
            }
            playOrPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        }
    }
    
    
    @IBAction func alterMusicTime(_ sender: UISlider) {
       updateSliderProgress()
    }
    
    
    func updateSliderProgress(){
        if let audioPlayer = audioPlayer {
            audioPlayer.stop()
            audioPlayer.currentTime = TimeInterval(musicSlider.value)
            currentTimeLabel.text = returnCurrentTimeInSong()
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            
            
        }
    }
    
    func musicSliderUpdate(){
        if let audioPlayer = audioPlayer {
            musicSlider.value = Float(audioPlayer.currentTime)
            currentTimeLabel.text = returnCurrentTimeInSong()
        }
    }
    
    @IBAction func nextSong(_ sender: UIButton) {
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
    
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        resetPlayerAndSliders()
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - Volume Slider
    
    @IBAction func changeVolume(_ sender: UISlider) {
        if let audioPlayer = audioPlayer {
            audioPlayer.volume = volumeSlider.value
        }
    }
    
    func resetPlayerAndSliders(){
        audioPlayer = nil
        musicSlider.value = 0
        volumeSlider.value = 0.5
    }
    
    
    
    
    
    
    func returnCurrentTimeInSong() -> String{
        if let audioPlayer = audioPlayer {
            if Int(audioPlayer.currentTime) < 10 {
                return "\(String(Int(audioPlayer.currentTime / 100))):0\(String(Int(audioPlayer.currentTime)))"
            }
            else {
                return "\(String(Int(audioPlayer.currentTime / 100))):\(String(Int(audioPlayer.currentTime)))"
            }
        }
        return "00:00"
    }
    
    
    
    
    
    
    
    func playSound(withURL url : URL) {
        do {
            try audioPlayer = AVAudioPlayer.init(data: Data(contentsOf: url), fileTypeHint: "mp3")
            
        }
        catch {
            print("assignment of audioplayer failed")
        }
        audioPlayer?.play()
    }
    
    
    
    
    func updateTitleSliderAndLabels(){
        navigationSongTitel.title = currentSong.songTitle
        
        currentTimeLabel.text = "00:00"
        endTimeLabel.text = "00:00"
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
