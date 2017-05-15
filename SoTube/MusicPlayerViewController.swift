//
//  MusicPlayerViewController.swift
//  SoTube
//
//  Created by VDAB Cursist on 12/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit

class MusicPlayerViewController: UIViewController {

    @IBOutlet weak var navigationSongTitel: UINavigationItem!
    
    @IBOutlet weak var albumImageView: UIImageView!
    
    @IBOutlet weak var songProgressView: UIProgressView!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBOutlet weak var endTimeLabel: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func previousSong(_ sender: UIButton) {
    }
    
    
    
    @IBAction func playSong(_ sender: UIButton) {
    }
    
    
    
    @IBAction func nextSong(_ sender: UIButton) {
    }
    
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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
