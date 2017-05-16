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
    @IBOutlet weak var songProgressView: UIProgressView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var playOrPauseButton: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                // Do any additional setup after loading the view.
        //navigationSongTitel.title = currentSong?.songTitle
        updateTitleSliderAndLabels()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    @IBAction func previousSong(_ sender: UIButton) {
        
        audioPlayer = nil
        if currentSongPositionInList != nil {
            if currentSongPositionInList == 0 {
                currentSongPositionInList = (songList?.count)! - 1
            }
            else {
                currentSongPositionInList! -= 1
            }
        }
        
        updateTitleSliderAndLabels()
    }
    
    
    
    @IBAction func playSong(_ sender: UIButton) {
        
        
        if audioPlayer != nil {
            if (audioPlayer?.isPlaying)! {
                audioPlayer?.pause()
                playOrPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
                
                displayLink?.invalidate()
            }
            else {
                audioPlayer?.play()
                playOrPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                displayLink = CADisplayLink(target: self, selector: (#selector(MusicPlayerViewController.updateSliderProgress)))
                displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            
            }
        }
        else {
            if songList != nil {
                //playSound(withURL: URL(string: (currentSong?.previewURLAssString)!)!)
                playSound(withURL: URL(string: (currentSong.previewURLAssString))!)
            }
            playOrPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            displayLink = CADisplayLink(target: self, selector: (#selector(MusicPlayerViewController.updateSliderProgress)))
            displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            
            if Int((audioPlayer?.duration)!) < 10 {
                endTimeLabel.text = "\(String(Int((audioPlayer?.duration)!/100))):0\(String(Int((audioPlayer?.duration)!)))"
            }
            else {
                endTimeLabel.text = "\(String(Int((audioPlayer?.duration)!/100))):\(String(Int((audioPlayer?.duration)!)))"
            }
        }
    }
    
    func updateSliderProgress(){
        if audioPlayer != nil {
            currentTimeLabel.text = returnCurrentTimeInSong()
            
            let progress = (audioPlayer?.currentTime)! / (audioPlayer?.duration)!
            songProgressView.setProgress(Float(progress), animated: false)
        }
    }
    
    @IBAction func nextSong(_ sender: UIButton) {
        audioPlayer = nil
        if currentSongPositionInList != nil {
            if currentSongPositionInList! == (songList?.count)!-1 {
                currentSongPositionInList = 0
            }
            else {
                currentSongPositionInList! += 1
            }
        }
        updateTitleSliderAndLabels()

    }
    
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        audioPlayer = nil
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    func returnCurrentTimeInSong() -> String{
        if Int((audioPlayer?.currentTime)!) < 10 {
            return "00:0\(String(Int((audioPlayer?.currentTime)!)))"
        }
        else {
            return "\(String(Int((audioPlayer?.currentTime)!/100))):\(String(Int((audioPlayer?.currentTime)!)))"
        }
    }
    
    
    
    
    
    
    
    func playSound(withURL url : URL) {
        do {
            try audioPlayer = AVAudioPlayer.init(data: Data(contentsOf: url), fileTypeHint: "mp3")
            
        }
        catch {print("assignment of audioplayer failed")}
        audioPlayer?.play()
    }
    
    
    
    
    func updateTitleSliderAndLabels(){
        navigationSongTitel.title = currentSong.songTitle
        
        currentTimeLabel.text = "00:00"
        endTimeLabel.text = "00:00"
        playOrPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        songProgressView.progress = 0
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
