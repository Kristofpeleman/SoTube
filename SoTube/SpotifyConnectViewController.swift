//
//  SpotifyConnectViewController.swift
//  SoTube
//
//  Created by Kristof Peleman on 16/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit

class SpotifyConnectViewController: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var startBtn: UIButton!
    
    
    // MARK: - Constants and Variables
    
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUp()
        NotificationCenter.default.addObserver(self, selector: #selector(SpotifyConnectViewController.updateAfterFirstLogin),name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - IBActions
    
    @IBAction func connectToSpotify(_ sender: UIButton) {
        if startBtn.currentTitle != "Start SoTube" {
            if UIApplication.shared.openURL(loginUrl!) {
                if auth.canHandle(auth.redirectURL) {
                    
                    // To do - build in error handling
                }
            }
        }
    }
    
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "TabBarControllerSegue" {

            let destinationVC = segue.destination as? UITabBarController
            
            for vc in destinationVC!.viewControllers! {
                let viewController = vc as? TopMediaViewController
                viewController?.auth = self.auth
                viewController?.session = self.session
            }
            
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "TabBarControllerSegue" {
            if startBtn.currentTitle == "Start SoTube" {
                return true
            }
            return false
        }
        return false
    }
 
    
    
    // MARK: - Homemade Functions
    
    func setUp() {
        SPTAuth.defaultInstance().clientID = "03b0f1c31eb44ef4b2a22e234d613da9"
        SPTAuth.defaultInstance().redirectURL = URL(string: "SoTube://returnAfterLogin")
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope]
        loginUrl = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()
    }
    
    func updateAfterFirstLogin () {
        startBtn.setTitle("Start SoTube", for: .normal)
        if let sessionObj:AnyObject = UserDefaults.standard.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            self.session = firstTimeSession
            
            
//            initializePlayer(authSession: session)
        }
    }
    
    func initializePlayer(authSession:SPTSession){
        if self.player == nil {
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            try! player!.start(withClientId: auth.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)
        }
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
        print("logged in")
        self.player?.playSpotifyURI("spotify:track:58s6EuEYJdlb0kO7awm3Vp", startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if (error != nil) {
                print("playing!")
            }
        })
    }

}
