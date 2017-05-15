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
    
    
    var currentSong: Song?
    var audioPlayer: AVAudioPlayer?

    @IBOutlet weak var navigationSongTitel: UINavigationItem!
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var songProgressView: UIProgressView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var playOrPauseButton: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                // Do any additional setup after loading the view.
        navigationSongTitel.title = currentSong?.songTitle
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    @IBAction func previousSong(_ sender: UIButton) {
    }
    
    
    
    @IBAction func playSong(_ sender: UIButton) {
        if audioPlayer != nil {
            if (audioPlayer?.isPlaying)! {
                audioPlayer?.pause()
                playOrPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            }
            else {
                audioPlayer?.play()
                playOrPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            }
        }
        else {
            playSound(withURL: URL(string: (currentSong?.previewURLAssString)!)!)
            playOrPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        }
    }
    
    
    
    @IBAction func nextSong(_ sender: UIButton) {
    }
    
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    func playSound(withURL url : URL) {
        do {
            try audioPlayer = AVAudioPlayer.init(data: Data(contentsOf: url), fileTypeHint: "mp3")
            
        }
        catch {print("assignment of audioplayer failed")}
        audioPlayer?.play()
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
