//
//  MySongsViewController.swift
//  SoTube
//
//  Created by VDAB Cursist on 09/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import Firebase

class MySongsViewController: TopMediaViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UISearchBarDelegate, LoginViewControllerDelegate, MusicPlayerViewControllerDelegate {
    
    // MARK: - Global variables and constants

    var shared = Shared.current

    var mySongs: [Song]?
    var filteredSongs: [Song] = []
    var currentPickerViewRow = 0
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logInButton: UIBarButtonItem!
    
    @IBOutlet weak var sortingPickerView: UIPickerView!
    @IBOutlet var sortingOptions: SortingOptions!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var goToMusicPlayerBarButton: UIBarButtonItem!
    
    @IBOutlet weak var shoppingCartAmountLabel: UILabel!
    
    
    // MARK: - UIViewController functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(auth ?? "AUTH is nil")
        print(session ?? "SESSION is nil")
        print(rootReference ?? "ROOT is nil")
        
        sortingPickerView.delegate = self
        sortingPickerView.dataSource = sortingOptions
        searchBar.delegate = self
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(FIRAuth.auth()?.currentUser ?? "NO FIRUser")
        print(FIRAuth.auth()?.currentUser?.displayName ?? "NO FIRUser displayName")
        
        self.songVCBackGroundImage.image = UIImage(named: self.shared.backGroundImage)
        
        if let user = shared.user {
            
            logInButton.title = "Log out"
            
            if let amountOfItemsInCart = user.shoppingCart?.count {
                shoppingCartAmountLabel.backgroundColor = UIColor.red
                shoppingCartAmountLabel.text = "\(amountOfItemsInCart)"
            } else {
                shoppingCartAmountLabel.backgroundColor = nil
                shoppingCartAmountLabel.text = ""
            }
            
            print(self.shared.user?.fireBaseID ?? "NO FIREBASE ID")
            print(self.shared.user?.userName ?? "NO USERNAME")
            print(self.shared.user?.emailAddress ?? "NO EMAIL")
            print(self.shared.user?.points ?? "NO POINTS")
            
        } else {
            logInButton.title = "Log in"
            self.mySongs = nil
            self.filteredSongs = []
        }
        
        if shared.user?.mySongs != nil {
            mySongs = shared.user?.mySongs
        }
        
        if shared.currentPositionInList != nil {
            goToMusicPlayerBarButton.isEnabled = true
        }
        else {
            goToMusicPlayerBarButton.isEnabled = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
        print(shared.user?.mySongs ?? "SHARED INSTANCE NOT FOUND")
        
        if shared.user == nil {
            let alertController = UIAlertController(title: "Log In",
                                                    message: "You need to log in before you can view your songs.",
                                                    preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: "OK",
                                         style: .cancel,
                                         handler: nil
            )
            
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - IBActions
    
    @IBAction func goToMusicPlayer(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "musicPlayerSegue", sender: sender)
    }
    
    
    // MARK: - Tableview DataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !filteredSongs.isEmpty {
            return filteredSongs.count
        }
        return (mySongs?.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongTableViewCell
        
        if !filteredSongs.isEmpty {
            cell.songTitleLabel.text = filteredSongs[indexPath.row].songTitle
            cell.artistNameLabel.text = filteredSongs[indexPath.row].artists
        }
        else if let mySongs = mySongs {
            cell.songTitleLabel.text = mySongs[indexPath.row].songTitle
            cell.artistNameLabel.text = mySongs[indexPath.row].artists
        }
        
        let border = CALayer()
        let width = CGFloat(0.3)
        border.borderColor = UIColor.gray.cgColor
        
        border.frame = CGRect(x: 0,
                              y: cell.frame.size.height - width,
                              width: cell.frame.size.width,
                              height: cell.frame.size.height
        )
        
        border.borderWidth = width
        cell.layer.addSublayer(border)
        cell.layer.masksToBounds = true

        return cell
    }
    
    
    // MARK: - Tableview Delegate methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.shared.currentPositionInList = indexPath.row
        performSegue(withIdentifier: "musicPlayerSegue", sender: nil)
    }
    
    
    
    
    // MARK: - Sort And Filter
    
    // Define the design of our UIview/UILabel in our rows
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        // Created local variable "label" of type "UILabel"
        var label: UILabel
        
        // If our view (parameter) exists/isn't nil when we read it as a UILabel
        if let view = view as? UILabel {
            // Then our label is that view
            label = view
            // Otherwise:
        } else {
            // Our label is a standard UILabel
            label = UILabel()
        }
        // Our words inside our label/row will always fit within the width, even if it has to change it's font-size
        label.adjustsFontSizeToFitWidth = true
        // The text inside our labels/rows will be the value from inside sortingOptions.values depending on the row we are currently on
        label.text = sortingOptions.values[row]
        
        
        return label
    }
    
    
    // Define what happens when we select a row
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // Change currentPickerViewRow's value to the selected row
        currentPickerViewRow = row
        
        
        if !filteredSongs.isEmpty {
            sortSongs(from: filteredSongs)
        }
            // Make sure songs exists/isn't nil
        else if mySongs != nil {
            // Call "sortSongs" function with parameter songs (unwrapped, since "songs" is of type "[Song]?" and we need something of type "[Song]" (+ we know it isn't nil at this point))
            sortSongs(from: shared.user!.mySongs!)
        }
        
    }
    
    // Function to sort our list/array containing elements of "Song"
    func sortSongs(from list: [Song]){
        // Local variable containing our parameter, because a parameter becomes a constant withing the function (even if the original wasn't)
        var sortedList = list
        
        // if the value in "sortingOptions.values[currentPickerViewRow]" is one of the following:
        switch sortingOptions.values[currentPickerViewRow] {
        case "Artist (A-Z)":
            // Sort our local list by artistNames from A-Z
            sortedList.sort(by: {$0.artistNames[0] < $1.artistNames[0]})
        case "Artist (Z-A)":
            // Sort our local list by artistNames from Z-A
            sortedList.sort(by: {$0.artistNames[0] > $1.artistNames[0]})
        case "Song Title (A-Z)":
            // Sort our local list by songTitle from A-Z
            sortedList.sort(by: {$0.songTitle < $1.songTitle})
        case "Song Title (Z-A)":
            // Sort our local list by songTitle from Z-A
            sortedList.sort(by: {$0.songTitle > $1.songTitle})
        // If it wasn't any of the above: stop the switch (prevents infinite loops)
        default: break
        }
        
        if !filteredSongs.isEmpty {
            filteredSongs = sortedList
        }
            // If songs exists/isn't empty
        else {
            mySongs = sortedList
        }
        
        // Reload the tableView to show either "filteredSongs" or "songs" with the sorted contents
        tableView.reloadData()
    }
    
    
    // MARK: - SearchBar
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" || mySongs == nil {
            filteredSongs = []
        }
        else {
            filteredSongs = mySongs!.filter(({ (song) -> Bool in
                return song.artistNames[0].lowercased().contains(searchText.lowercased())
            }))
            filteredSongs += mySongs!.filter(({ (song) -> Bool in
                if song.artistNames.count > 1 {
                    if !filteredSongs.contains(where: {$0.spotify_ID == song.spotify_ID}) {
                        return song.artistNames[1].lowercased().contains(searchText.lowercased())
                    }
                }
                return false
            }))
            filteredSongs += mySongs!.filter(({ (song) -> Bool in
                if !filteredSongs.contains(where: {$0.spotify_ID == song.spotify_ID}){
                    return song.songTitle.lowercased().contains(searchText.lowercased())
                }
                return false
            }))
            
        }
        pickerView(sortingPickerView, didSelectRow: currentPickerViewRow, inComponent: 0)
        tableView.reloadData()
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
                destinationVC.delegate = self
                
                if sender is UIBarButtonItem {
                    destinationVC.songList = self.shared.songList
                    destinationVC.currentSongPositionInList = self.shared.currentPositionInList
                }
                else {
                    if !filteredSongs.isEmpty {
                        destinationVC.songList = self.filteredSongs
                    }
                    else {
                        destinationVC.songList = self.mySongs
                    }
                    destinationVC.currentSongPositionInList = self.shared.currentPositionInList

                }
                destinationVC.currentUser = self.shared.user
                
                if let _ = self.shared.user {
                    
                    let usersReference: FIRDatabaseReference = rootReference!.child("Users")
                    let thisUserReference = usersReference.child(self.shared.user!.fireBaseID)
                    
                    destinationVC.userReference = thisUserReference
                }
                
            }
        }
        
        if segue.identifier == "shoppingCartSegue" {
            if let destinationVC = segue.destination as? ShoppingCartViewController {
                
                destinationVC.auth = self.auth
                destinationVC.session = self.session
                destinationVC.currentUser = self.shared.user
                
                let usersReference = rootReference?.child("Users")
                destinationVC.userReference = usersReference?.child(self.shared.user!.fireBaseID)
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
                self.mySongs = nil
                self.filteredSongs = []
                
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
            
        case "musicPlayerSegue":
            
            if sender is UIBarButtonItem {
                if let _ = self.shared.songList, let _ = self.shared.currentPositionInList {
                    return true
                }
                return false
                
            }
            else {
                return true
            }
            
        case "shoppingCartSegue":
            
            if let _ = shared.user {
                return true
            }
            else {
                
                let alertController = UIAlertController(title: "Log In",
                                                        message: "You can not have a shoppingcart without being logged in.",
                                                        preferredStyle: .alert
                )
                
                let okAction = UIAlertAction(title: "OK",
                                             style: .cancel,
                                             handler: nil
                )
                
                alertController.addAction(okAction)
                
                present(alertController, animated: true, completion: nil)

                
                return false
            }
            
        // If the identifier's value isn't any of the above: perform Segue
        default: return true
        }
    }
    
    // MARK: - LoginViewControllerDelegate methods
    
    func setUser(_ user: User) {
        self.shared.user = user
    }
    
    // MARK: - MusicPlayerViewControllerDelegate methods
    
    func setSongList(_ songList: [Song]) {
        self.shared.songList = songList
    }
    
    func setCurrentPositionInList(_ position: Int) {
        self.shared.currentPositionInList = position
    }
    

}
