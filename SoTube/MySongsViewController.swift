//
//  MySongsViewController.swift
//  SoTube
//
//  Created by VDAB Cursist on 09/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import Firebase

class MySongsViewController: TopMediaViewController, UITableViewDelegate, UITableViewDataSource {
    
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
        print(rootReference ?? "ROOT is nil")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(FIRAuth.auth()?.currentUser ?? "NO FIRUser")
        print(FIRAuth.auth()?.currentUser?.displayName ?? "NO FIRUser displayName")
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
        cell.costLabel.text = String(describing: shared.user?.mySongs![indexPath.row].cost)
        
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
            if let _ = segue.destination as? LogInViewController {
                
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
    

}
