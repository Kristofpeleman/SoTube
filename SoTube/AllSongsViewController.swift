//
//  AllSongsViewController.swift
//  SoTube
//
//  Created by VDAB Cursist on 09/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import Firebase

class AllSongsViewController: TopMediaViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UISearchBarDelegate, LoginViewControllerDelegate, MusicPlayerViewControllerDelegate {
    
    // MARK: - Variables and constants

    var shared = Shared.current

    // Created a constant containing the feed-urls (as Strings) from ViewModel()
    let feedURLs = ViewModel().feeds
    // Created a constant containing the feed-urls (as Strings) from TopMediaViewModel()
    let newReleasesFeed = TopMediaViewModel().newReleasesURLAsString
    
    
    
    // Variable to lessen the amount of "magic" numbers in the app
    let tableViewSongLimit = 50
    // Created an optional variable "songs"-array containing elements of class "Song"
    var songs: [Song]? {
        // When the value changes
        didSet {
            if songs != nil {
                // !!!! REMEMBER: Count starts at 1, an array-positioning/index starts at 0
                // If there are 50 items in the array
                if songs!.count == tableViewSongLimit {
                    // print the 49th position in the array (= item 50)
                    //print(songs![49])
                    
                    print(String(songs!.count) + " SONGS")
                    
                    // reload the tableView to show all the new items
                    self.tableView.reloadData()
                    
                    self.stopIndicator()
                }
            }
        }
    }
    
    
    // Current row in the pickerView ("sort by")
    var currentPickerViewRow = 0
    
    // An optional array of Strings defining the ID's of the albumstracks the songs are from
    var albumIDs: [String]? {
        // When value changes
        didSet {
            // prints itself
                print(albumIDs!)
            // Get the ID's of the tracks
                getTrackIDs()
        }
    }
    
    // The trackIDs in optional array of Strings
    var trackIDs: [String]?
        {
        // When value changes
        didSet {
            // If there are 50 items in the array
            if trackIDs!.count == tableViewSongLimit {
                // Print our array
                print(trackIDs!)
                // local constant is a temporary array that puts the values in our trackIDs between these strings
                let feeds = trackIDs!.map{"https://api.spotify.com/v1/tracks/" + $0 + "?"}
                // Use the local array in the function "setSongsFromJSONFeed()"
                setSongsFromJSONFeed(jsonData: feeds)
                
            }
        }
    }
    
    // calculated variable, optional array
    var albumFeeds: [String]? {
        // puts the values in our albumIDs between these strings and becomes the value of albumFeeds
        return self.albumIDs?.map{"https://api.spotify.com/v1/albums/" + $0 + "?"}
    }
    
    let activityIndicator = UIActivityIndicatorView()
    
    var loadingTimer: Timer?
    
    
    // MARK: - Outlets
    // Button
    @IBOutlet weak var logInButton: UIBarButtonItem!
    // PickerView and its parts
    @IBOutlet weak var sortingPickerView: UIPickerView!
    @IBOutlet var sortingOptions: SortingOptions!
    
    // TableView
    @IBOutlet weak var tableView: UITableView!
    // SearchBar
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var goToMusicPlayerButton: UIBarButtonItem!
    
    
    
    // MARK: - Standard Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color? = .black
        activityIndicator.center = self.view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        // Login
        print(auth ?? "AUTH is nil")
        print(session ?? "SESSION is nil")
                
        
        // Set dataSource for pickerView and TableView
        sortingPickerView.dataSource = sortingOptions
        tableView.dataSource = self
        // Set delegate for searchBar
        searchBar.delegate = self
        
        // Call function "getAlbumIDs()"
        getAlbumIDs()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Own override functions
    
    // When the View is going to show itself
    override func viewWillAppear(_ animated: Bool) {
        // Print who is logged into FireBase
        print(FIRAuth.auth()?.currentUser ?? "NO FIRUser")
        print(FIRAuth.auth()?.currentUser?.displayName ?? "NO FIRUser displayName")
        
        self.songVCBackGroundImage.image = UIImage(named: self.shared.backGroundImage)
        
        if let _ = shared.user {
            
            logInButton.title = "Log out"
            
            print(self.shared.user?.fireBaseID ?? "NO FIREBASE ID")
            print(self.shared.user?.userName ?? "NO USERNAME")
            print(self.shared.user?.emailAddress ?? "NO EMAIL")
            print(self.shared.user?.points ?? "NO POINTS")
            
        } else {
            logInButton.title = "Log in"
        }
        
        
        if shared.currentPositionInList != nil {
            goToMusicPlayerButton.isEnabled = true
        }
        else {
            goToMusicPlayerButton.isEnabled = false
        }
        
    }
    
    // When the View just showed itself
    override func viewDidAppear(_ animated: Bool) {
        sleep(1)
        tableView.reloadData()
        stopIndicator()
    }
    
    
    // MARK: - IBActions
    
    @IBAction func goToMusicPlayer(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "musicPlayerSegue", sender: sender)
    }
    
    
    
    func stopIndicator(){
        activityIndicator.stopAnimating()
        tableView.isUserInteractionEnabled = true
    }
    
    func longLoadingAlert(){
        if activityIndicator.isAnimating{
            let alertController = UIAlertController(title: "Long Loading Time", message: "The app can't seem to find 50+ results for your search.\nWould you like to keep waiting for results?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: nil)
            let noAction = UIAlertAction(title: "No", style: .default, handler: { (action) in
                self.tableView.reloadData()
                self.stopIndicator()
            })
            alertController.addAction(noAction)
            alertController.addAction(yesAction)
            self.present(alertController, animated: true, completion: nil)
            loadingTimer?.invalidate()
        }
    }
    
    // MARK: - TableView Datasource Methods
    
    // Define how many rows there are in our tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If songs?.count isn't nil -> use that count, else use 1
        return (songs?.count) ?? 0
    
    }
    
    // Define what is inside each row/cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Created a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongTableViewCell
        
        
        // If songs exists/isn't nil
        if let songs = self.songs {
            // Call "alterTableViewLabels" with "songs" as parameter
            alterTableViewLabels(forSongList: songs, inCell: cell, atRow: indexPath.row)
        }
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    // What to do when a row is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activityIndicator.startAnimating()
        tableView.isUserInteractionEnabled = false
        // The current position in our array is the row we just clicked on
        shared.currentPositionInList = indexPath.row
        
        /*
         let song = self.songs?[currentSongPositionInList]
         
         if let _ = song?.fullSongURLAssString {
         performSegue(withIdentifier: "playerSegue", sender: nil)
         }*/
        
        //playSound(withURL: URL(string: (self.songs?[indexPath.row].previewURLAssString)!)!)
        // Perform the following segue to a new ViewController
        performSegue(withIdentifier: "musicPlayerSegue", sender: self.tableView)
        
    }
    

    // Function to change the labels in SongTableViewCell, depending on a row (Int) and list/array ([Song])
    func alterTableViewLabels(forSongList list: [Song], inCell cell: SongTableViewCell, atRow row: Int){
    
        cell.artistNameLabel.text = list[row].artists
        cell.songTitleLabel.text = list[row].songTitle
        cell.costLabel.text = String(describing: list[row].cost) // Cost is an Int, so to get it as string we couldn't use String(), so we used String(describing: )
 
    }
    
    
    
    // MARK: - PickerView
    
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
        
        // Make sure songs exists/isn't nil
        if songs != nil {
            // Call "sortSongs" function with parameter songs (unwrapped, since "songs" is of type "[Song]?" and we need something of type "[Song]" (+ we know it isn't nil at this point))
            sortSongs(from: songs!)
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
        
        
        // If songs exists/isn't empty
        if songs != nil {
            songs = sortedList
        }
        
        // Reload the tableView to show either "filteredSongs" or "songs" with the sorted contents
        tableView.reloadData()
    }

    
    // MARK: - SearchBar
    
    // When you press "enter"/"return" in the searchBar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        activityIndicator.startAnimating()
        tableView.isUserInteractionEnabled = false
        
        if loadingTimer != nil {
            loadingTimer?.invalidate()
        }
        loadingTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.longLoadingAlert), userInfo: nil, repeats: false)
        
        // Local constant containing the text of the searchBar
        let keywords = searchBar.text
        // Local constant containging the one above, but every empty space turns into a "+"
        let query = keywords?.replacingOccurrences(of: " ", with: "+")
        // Local constant containing a url (containing our query) as a string
        let searchFeed = "https://api.spotify.com/v1/search?q=\(query!)&type=track&limit=50"
        // Set songs to nil
        self.songs = nil
        // Call function "getSearchResponse" with our "searchFeed" as a parameter
        getSearchResponse(searchFeed: searchFeed)
        
    }
    
    
    
    // MARK: - Segue
    
    // Function that will automaticly happen when a segue is triggered/performed
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // If the segue that is being called uses "musicPlayerSegue" as identifier
        if segue.identifier == "musicPlayerSegue" {
            // If we have a destination that isn't nil if we try to use it as a MusicPlayerViewController
            if let destinationVC = segue.destination as? MusicPlayerViewController {
                
                // Set the FireBase authentication and session
                destinationVC.auth = self.auth
                destinationVC.session = self.session
                destinationVC.delegate = self
                
                if sender is UIBarButtonItem {
                    destinationVC.songList = self.shared.songList
                    destinationVC.currentSongPositionInList = self.shared.currentPositionInList

                } else {
                    
                    // If this VC's "songs" exists/isn't nil
                    if songs != nil {
                        // Give the "songList" in our destination the value of this VC's "songs"
                        destinationVC.songList = songs
                    }
                    
                    // Give the "currentSongPositionInList" in our destination the value of this VC's "currentSongPositionInList"
                    destinationVC.currentSongPositionInList = self.shared.currentPositionInList
                }
                
                // Same as above for these 2
                destinationVC.currentUser = self.shared.user
                
                if let _ = self.shared.user {
                
                let usersReference: FIRDatabaseReference = rootReference!.child("Users")
                let thisUserReference = usersReference.child(self.shared.user!.fireBaseID)
                
                destinationVC.userReference = thisUserReference
                }
                
            }
        }
        
        // If the segue that is being called uses "playerSegue" as identifier
        if segue.identifier == "playerSegue" {
            // If we have a destination that isn't nil if we try to use it as a PlayerViewController
            if let destinationVC = segue.destination as? PlayerViewController {
                
                // Set the FireBase authentication and session
                destinationVC.auth = self.auth
                destinationVC.session = self.session
                
                
                // If this VC's "songs" exists/isn't nil
                if songs != nil {
                    // Give the "songList" in our destination the value of this VC's "songs"
                    destinationVC.songList = songs
                }
                
                // Give the "currentSongPositionInList" in our destination the value of this VC's "currentSongPositionInList"
                destinationVC.currentSongPositionInList = self.shared.currentPositionInList
            }
        }
        
        // If the segue that is being called uses "loginSegue" as identifier
        if segue.identifier == "loginSegue" {
            // If we have a destination that isn't nil if we try to use it as a LogInViewController
            if let destinationVC = segue.destination as? LogInViewController {
                // This VC is the destination's delegate
                destinationVC.delegate = self
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
                //                self.userReference = nil
                //                self.userID = nil
                
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
                
            } else {return true}
            
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
    
    
    // MARK: - JSON
    
    func setSongsFromJSONFeed(jsonData: [String]) {
        
        for json in jsonData {
            
            let request = try? SPTRequest.createRequest(for: URL(string: json)!, withAccessToken: session?.accessToken, httpMethod: "get", values: nil, valueBodyIsJSON: true, sendDataAsQueryString: true)
            
//            let request = URLRequest(url: URL(string: json)!)
            let session1 = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
            let task = session1.dataTask(with: request!) {
                data, response, error in
                if let jsonData = data,
                    let feed = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)) as? NSDictionary,
                    let songName = feed.value(forKeyPath: "name") as? String,
                    let artists = feed.value(forKeyPath: "artists") as? NSArray,
                    let spotify_ID = feed.value(forKeyPath: "id") as? String,
                    let preview_url = feed.value(forKeyPath: "preview_url") as? String,
                    let duration = feed.value(forKeyPath: "duration_ms") as? Int,
                    let images = feed.value(forKeyPath: "album.images") as? NSArray
                {
                    var allArtists: [String] = []
                    for dictionary in artists {
                        allArtists.append((dictionary as! NSDictionary).value(forKey: "name") as! String? ?? "NOT FOUND")
                        
                        
                    }
                    let image = images[0] as! NSDictionary
                    let imageURL = image.value(forKeyPath: "url") as? String
                    
                    if let _ = self.songs {
                        self.songs!.append(Song(songTitle: songName, artistNames: allArtists, spotify_ID: spotify_ID, duration: duration/1000, imageURLAssString: imageURL!, previewURLAssString: preview_url))
                    } else {
                        self.songs = [Song(songTitle: songName, artistNames: allArtists, spotify_ID: spotify_ID, duration: duration/1000, imageURLAssString: imageURL!, previewURLAssString: preview_url)]
                    }
                    
                }
            }
            
            
            task.resume()
        }
    }
    
    func getAlbumIDs() {
        
        let request = try? SPTRequest.createRequest(for: URL(string: newReleasesFeed)!, withAccessToken: session?.accessToken, httpMethod: "get", values: nil, valueBodyIsJSON: true, sendDataAsQueryString: true)
        
        print(request!.allHTTPHeaderFields ?? "NO HTTP HEADER FIELDS")
        print(request?.url ?? "MISSING URL")
        
        let session1 = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        let task = session1.dataTask(with: request!) {
            data, response, error in
            if let jsonData = data,
                let feed = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)) as? NSDictionary,
                let albumItems = feed.value(forKeyPath: "albums.items") as? NSArray
                
            {

                var albumIDArray: [String] = []
                for dictionary in albumItems {
                    albumIDArray.append((dictionary as! NSDictionary).value(forKey: "id") as! String? ?? "NOT FOUND")
                    
                }
                self.albumIDs = albumIDArray
                
            }
        }
        
        task.resume()
    }
    
    func getTrackIDs() {
        
        for feed in self.albumFeeds! {
        
            let request = try? SPTRequest.createRequest(for: URL(string: feed)!, withAccessToken: session?.accessToken, httpMethod: "get", values: nil, valueBodyIsJSON: true, sendDataAsQueryString: true)
            
            let session1 = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
            let task = session1.dataTask(with: request!) {
                data, response, error in
                if let jsonData = data,
                    let feed = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)) as? NSDictionary,
                    let trackItems = feed.value(forKeyPath: "tracks.items") as? NSArray
                    
                {
                    
                    let firstTrack = trackItems[0] as! NSDictionary
                    
                    if let _ = self.trackIDs {
                        self.trackIDs?.append(firstTrack.value(forKeyPath: "id") as! String)
                    } else {self.trackIDs = [firstTrack.value(forKeyPath: "id") as! String]}
                    
                }
                else {
                    print("Error getting track IDs")
                }
            }
            
            task.resume()
        }
    }
    
    func getSearchResponse(searchFeed: String) {
        
            let request = try? SPTRequest.createRequest(for: URL(string: searchFeed)!, withAccessToken: session?.accessToken, httpMethod: "get", values: nil, valueBodyIsJSON: true, sendDataAsQueryString: true)
            
            let session1 = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
            let task = session1.dataTask(with: request!) {
                data, response, error in
                if let jsonData = data,
                    let feed = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)) as? NSDictionary,
                    let tracksArray = feed.value(forKeyPath: "tracks.items") as? NSArray
                    
                {
                    var IDsArray: [String] = []
                    for dictionary in tracksArray {
                        IDsArray.append((dictionary as! NSDictionary).value(forKeyPath: "id") as! String)
                    }
                    
                    self.trackIDs = IDsArray
                    
                }

            }
            
        task.resume()
    }
    
    
    
}



