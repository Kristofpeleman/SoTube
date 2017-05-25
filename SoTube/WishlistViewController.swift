//
//  WishlistViewController.swift
//  SoTube
//
//  Created by VDAB Cursist on 09/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import Firebase

class WishlistViewController: TopMediaViewController, UITableViewDelegate, UITableViewDataSource, LoginViewControllerDelegate {
    
    // MARK: - Global variables and constants
    
    var shared = Shared.current
    
    var currentSongPositionInList = 0

    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logInButton: UIBarButtonItem!
    
    
    // MARK: - UIViewController functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(auth ?? "AUTH is nil")
        print(session ?? "SESSION is nil")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(FIRAuth.auth()?.currentUser ?? "NO FIRUser")
        print(FIRAuth.auth()?.currentUser?.displayName ?? "NO FIRUser displayName")
        
//        self.sharedUser = shared.user
        
        if let _ = shared.user {
            logInButton.title = "Log out"
            
            print(self.shared.user?.fireBaseID ?? "NO FIREBASE ID")
            print(self.shared.user?.userName ?? "NO USERNAME")
            print(self.shared.user?.emailAddress ?? "NO EMAIL")
            print(self.shared.user?.points ?? "NO POINTS")
            
        } else {
            logInButton.title = "Log in"
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
        print(shared.user?.wishList ?? "SHARED INSTANCE NOT FOUND")
    }
    
    
    // MARK: - Tableview DataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (shared.user?.wishList?.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongTableViewCell
        
        cell.songTitleLabel.text = shared.user?.wishList![indexPath.row].songTitle
        cell.artistNameLabel.text = shared.user?.wishList![indexPath.row].artists
        cell.costLabel.text = String(describing: shared.user?.wishList![indexPath.row].cost)
        
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
                destinationVC.songList = self.shared.user?.wishList
                destinationVC.currentSongPositionInList = self.currentSongPositionInList
                destinationVC.currentUser = self.shared.user
                
                let usersReference: FIRDatabaseReference = rootReference!.child("Users")
                let userID = shared.user!.fireBaseID
                
                destinationVC.userReference = usersReference.child(userID)
                
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
    
    func setUser(_ user: User) {
        self.shared.user = user
    }
    

}
