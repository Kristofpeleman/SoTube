//
//  AfterLaunchScreenViewController.swift
//  SoTube
//
//  Created by Robin Rega on 26/05/2017.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import AVFoundation

class AfterLaunchScreenViewController: UIViewController {

    
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadVideo()

        self.perform(#selector(self.performSegueToStart), with: nil, afterDelay: 5)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func loadVideo(){
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        }
        catch {}
        let path = Bundle.main.path(forResource: "SoTubeLogoVidFade", ofType: ".mp4")
        
        let url = URL(fileURLWithPath: path!)
        
        player = AVPlayer(url: url)
        
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = self.view.frame
        playerLayer.zPosition = -1
        
        self.view.layer.addSublayer(playerLayer)
        
        player?.seek(to: kCMTimeZero)
        player?.play()
    }
    
    func performSegueToStart(){
        player = nil
        performSegue(withIdentifier: "initialSegue", sender: nil)
    }

}
