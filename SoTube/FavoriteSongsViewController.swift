//
//  FavoriteSongsViewController.swift
//  SoTube
//
//  Created by VDAB Cursist on 09/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import Firebase

class FavoriteSongsViewController: TopMediaViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Global variables and constants
    
    var shared = Shared.current
    var currentSongPositionInList = 0
    var mySongs: [Song]? {
        return shared.user?.mySongs
    }
    var myFavoriteSongs: [Song]? {
        return mySongs?.filter{$0.favorite == true}
    }

    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
        print(shared.user?.mySongs ?? "SHARED INSTANCE NOT FOUND")
        print(self.myFavoriteSongs ?? "FAVORITE SONGS NOT FOUND")
    }
    
    // MARK: - Tableview DataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (myFavoriteSongs?.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongTableViewCell
        
        cell.songTitleLabel.text = myFavoriteSongs?[indexPath.row].songTitle
        cell.artistNameLabel.text = myFavoriteSongs?[indexPath.row].artists
        cell.costLabel.text = String(describing: myFavoriteSongs?[indexPath.row].cost)
        
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
                destinationVC.songList = self.myFavoriteSongs
                destinationVC.currentSongPositionInList = self.currentSongPositionInList
                destinationVC.currentUser = self.shared.user
                
                let usersReference: FIRDatabaseReference = (rootReference?.child("Users"))!
                let userID = shared.user?.fireBaseID
                
                destinationVC.userReference = usersReference.child(userID!)
                
            }
        }
    }
    

}
