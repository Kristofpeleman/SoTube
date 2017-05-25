//
//  MySongsViewController.swift
//  SoTube
//
//  Created by VDAB Cursist on 09/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import Firebase

class MySongsViewController: TopMediaViewController, UITableViewDelegate, UITableViewDataSource, LoginViewControllerDelegate {
    
    // MARK: - Global variables and constants
    private var userReference: FIRDatabaseReference?
    private var userID: String?
    var shared = Shared.current

    var sharedUser: User? {
        willSet (newValue) {
            if newValue == nil {
                userReference = nil
                userID = nil
            }
        }
    }
    
    
    var currentSongPositionInList = 0
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logInButton: UIBarButtonItem!
    
    
    // MARK: - UIViewController functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(auth ?? "AUTH is nil")
        print(session ?? "SESSION is nil")
        print(rootReference ?? "ROOT is nil")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(FIRAuth.auth()?.currentUser ?? "NO FIRUser")
        print(FIRAuth.auth()?.currentUser?.displayName ?? "NO FIRUser displayName")
        
        self.sharedUser = shared.user
        
        if let _ = shared.user {
            logInButton.title = "Log out"
        } else {
            logInButton.title = "Log in"
        }
        
        
        if let reference = self.userReference {
            
            // The title of logInButton has to change
            logInButton.title = "Log out"
            
            reference.observe(.value, with: {snapshot in
                
                self.shared.user = User(with: snapshot)
                
            })
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
        print(shared.user?.mySongs ?? "SHARED INSTANCE NOT FOUND")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Tableview DataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (shared.user?.mySongs?.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongTableViewCell
        
        cell.songTitleLabel.text = shared.user?.mySongs![indexPath.row].songTitle
        cell.artistNameLabel.text = shared.user?.mySongs![indexPath.row].artists
        
        return cell
    }
    
    
    // MARK: - Tableview Delegate methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentSongPositionInList = indexPath.row
        performSegue(withIdentifier: "musicPlayerSegue", sender: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "loginSegue" {
            if let destinationVC = segue.destination as? LogInViewController {
                destinationVC.delegate = self
            }
        }
        
        if segue.identifier == "musicPlayerSegue" {
            if let destinationVC = segue.destination as? MusicPlayerViewController {
                destinationVC.auth = self.auth
                destinationVC.session = self.session
                destinationVC.songList = self.shared.user?.mySongs
                destinationVC.currentSongPositionInList = self.currentSongPositionInList
                destinationVC.currentUser = self.shared.user
                
                let usersReference: FIRDatabaseReference = (rootReference?.child("Users"))!
                let userID = shared.user?.fireBaseID
                
                destinationVC.userReference = usersReference.child(userID!)
                
            }
        }
        
    }
    
    // An override function when performing a segue
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        // Check the value of "identifier"
        switch identifier {
        // If the value is "loginSegue"
        case "loginSegue":
            // If "logInButton"'s title is "Log out"
            if logInButton.title == "Log out" {
                
                // Get the user that is logged in his/her online-status from FireBase
                let currentOnlineUserReference = FIRDatabase.database().reference(withPath: "online users/\(self.shared.user!.fireBaseID)")
                // Remove the value of the online-status (make it go offline)
                currentOnlineUserReference.removeValue()
                
                // Since the value isn't in FireBase anymore, we must delete it localy
                self.shared.user = nil
                self.userReference = nil
                self.userID = nil
                
                self.tableView.reloadData()
                // Change "logInButton"'s title to "Log in"
                logInButton.title = "Log in"
                
                // Leave the function with the return and don't perform the segue
                return false
            }
                // If "logInButton"'s title isn't "Log out"
            else {
                // Perform the segue
                return true
            }
        // If the identifier's value isn't any of the above: perform Segue
        default: return true
        }
    }
    
    // MARK: - LoginViewControllerDelegate methods
    
    func setUserID(_ id: String) {
        // Give "userID" the value of "id"
        self.userID = id
    }
    
    func setUserReference(_ ref: FIRDatabaseReference) {
        // Give "userReference" the value of "ref"
        self.userReference = ref
    }
    

}
