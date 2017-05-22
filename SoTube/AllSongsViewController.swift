//
//  AllSongsViewController.swift
//  SoTube
//
//  Created by VDAB Cursist on 09/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import Firebase

class AllSongsViewController: TopMediaViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UISearchBarDelegate, LoginViewControllerDelegate {
    
//    private var onlineUsersReference: FIRDatabaseReference?
    private var userReference: FIRDatabaseReference?
    private var userID: String?
    var currentUser: User?{
        didSet {
            let mainTabBarController:UITabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
            
            for vc in mainTabBarController.childViewControllers {
                if vc is MySongsViewController {
                    (vc as! MySongsViewController).currentUser = self.currentUser
                }
                if vc is FavoriteSongsViewController {
                    (vc as! FavoriteSongsViewController).currentUser = self.currentUser
                }
                if vc is WishlistViewController {
                    (vc as! WishlistViewController).currentUser = self.currentUser
                }
            }
        }
    
    }
    
    
    let feedURLs = ViewModel().feeds
    let newReleasesFeed = TopMediaViewModel().newReleasesURLAsString
    
    
    
    var currentSongPositionInList = 0
    var songs: [Song]? {
        didSet {
//            print(String(songs!.count) + " SONGS")
            if songs?.count == 50 {
                print(songs![49])
                print(String(songs!.count) + " SONGS")
                
                self.tableView.reloadData()
            }
        }
    }
    
    var filteredSongs: [Song] = []
    var currentPickerViewRow = 0
    
    var albumIDs: [String]? {
        didSet {
                print(albumIDs!)
                getTrackIDs()
        }
    }
    
    var trackIDs: [String]?
        {
        didSet {
            if trackIDs!.count == 50 {
                print(trackIDs!)
                let feeds = trackIDs!.map{"https://api.spotify.com/v1/tracks/" + $0 + "?"}
                setSongsFromJSONFeed(jsonData: feeds)
            }
        }
    }
    
    var albumFeeds: [String]? {
        return self.albumIDs?.map{"https://api.spotify.com/v1/albums/" + $0 + "?"}
    }
    
    
    
    @IBOutlet weak var logInButton: UIBarButtonItem!
    @IBOutlet weak var sortingPickerView: UIPickerView!
    @IBOutlet var sortingOptions: SortingOptions!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(auth ?? "AUTH is nil")
        print(session ?? "SESSION is nil")
        
//        onlineUsersReference = FIRDatabase.database().reference(withPath: "online users")
//        onlineUsersReference?.observe(.value, with: {snapshot in
//            self.userName = FIRAuth.auth()?.currentUser?.displayName ?? ""
//            if snapshot.hasChild(self.userName!) {
//                let userReference = FIRDatabase.database().reference(withPath: "Users/\(self.userName!)")
//                print(userReference.key)
//                print(userReference.key)
//                print(userReference)
//                self.online = true
//                print(self.online)
//            }
//        })
        
    
        sortingPickerView.dataSource = sortingOptions
        tableView.dataSource = self
        searchBar.delegate = self
        
        getAlbumIDs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(FIRAuth.auth()?.currentUser ?? "NO FIRUser")
        print(FIRAuth.auth()?.currentUser?.displayName ?? "NO FIRUser displayName")
        
        if let reference = self.userReference {
            logInButton.title = "Log out"

            reference.observe(.value, with: {snapshot in

                self.currentUser = User(with: snapshot)
                print(self.currentUser?.fireBaseID ?? "NO FIREBASE ID")
                print(self.currentUser?.userName ?? "NO USERNAME")
                print(self.currentUser?.emailAddress ?? "NO EMAIL")
                print(self.currentUser?.points ?? "NO POINTS")
            })
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
        
    }
    
    
    // MARK: - TableView Datasource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !filteredSongs.isEmpty {
            return filteredSongs.count
        }
        return (songs?.count) ?? 1
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongTableViewCell
        
        if !filteredSongs.isEmpty {
            alterTableViewLabels(forSongList: filteredSongs, inCell: cell, atRow: indexPath.row)
        }
        else {
            if let songs = self.songs {
                alterTableViewLabels(forSongList: songs, inCell: cell, atRow: indexPath.row)
            }
        }
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //currentSong = self.filteredSongs[indexPath.row]
        currentSongPositionInList = indexPath.row
        
        /*
        let song = self.songs?[currentSongPositionInList]
        
        if let _ = song?.fullSongURLAssString {
            performSegue(withIdentifier: "playerSegue", sender: nil)
        }*/
        
        //playSound(withURL: URL(string: (self.songs?[indexPath.row].previewURLAssString)!)!)
        performSegue(withIdentifier: "musicPlayerSegue", sender: nil)
    }
    

    
    
    
    func alterTableViewLabels(forSongList list: [Song], inCell cell: SongTableViewCell, atRow row: Int){
        cell.artistNameLabel.text = list[row].artists
        cell.songTitleLabel.text = list[row].songTitle
        cell.costLabel.text = String(describing: list[row].cost)
 
    }
    
    
    
    // MARK: - PickerView
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        
        label.adjustsFontSizeToFitWidth = true
        label.text = sortingOptions.values[row]
        
        
        return label
    }

    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        currentPickerViewRow = row
        
        if !filteredSongs.isEmpty{
            sortSongs(from: filteredSongs)
        }
        else if songs != nil {
            sortSongs(from: songs!)
        }
        
        
    }

    func sortSongs(from list: [Song]){
        var sortedList = list
        
        switch sortingOptions.values[currentPickerViewRow] {
        case "Artist (A-Z)":
            sortedList.sort(by: {$0.artistNames[0] < $1.artistNames[0]})
        case "Artist (Z-A)":
            sortedList.sort(by: {$0.artistNames[0] > $1.artistNames[0]})
        case "Song Title (A-Z)":
            sortedList.sort(by: {$0.songTitle < $1.songTitle})
        case "Song Title (Z-A)":
            sortedList.sort(by: {$0.songTitle > $1.songTitle})
        default: break
        }
        if !filteredSongs.isEmpty {
            filteredSongs = sortedList
        }
        else {
            songs = sortedList
        }
        
        tableView.reloadData()
    }

    
    // MARK: - SearchBar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" || songs == nil {
            filteredSongs = []
        }
        else {
            filteredSongs = songs!.filter(({ (song) -> Bool in
                return song.artistNames[0].lowercased().contains(searchText.lowercased())
            }))
            filteredSongs += songs!.filter(({ (song) -> Bool in
                if song.artistNames.count > 1 {
                    if !filteredSongs.contains(where: {$0.spotify_ID == song.spotify_ID}) {
                        return song.artistNames[1].lowercased().contains(searchText.lowercased())
                    }
                }
                return false
            }))
            filteredSongs += songs!.filter(({ (song) -> Bool in
                if !filteredSongs.contains(where: {$0.spotify_ID == song.spotify_ID}){
                    return song.songTitle.lowercased().contains(searchText.lowercased())
                }
                return false
            }))
            
        }
        pickerView(sortingPickerView, didSelectRow: currentPickerViewRow, inComponent: 0)
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keywords = searchBar.text
        let query = keywords?.replacingOccurrences(of: " ", with: "+")
        let searchFeed = "https://api.spotify.com/v1/search?q=\(query!)&type=track&limit=50"
        self.songs = nil
        getSearchResponse(searchFeed: searchFeed)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "musicPlayerSegue" {
            if let destinationVC = segue.destination as? MusicPlayerViewController {
                //destinationVC.currentSong = self.currentSong
                
                destinationVC.auth = self.auth
                destinationVC.session = self.session
                
                if !filteredSongs.isEmpty {
                    destinationVC.songList = filteredSongs
                }
                else if songs != nil {
                    destinationVC.songList = songs
                }
                destinationVC.currentSongPositionInList = self.currentSongPositionInList
                destinationVC.currentUser = self.currentUser
                destinationVC.userReference = self.userReference
            }
        }
        
        if segue.identifier == "playerSegue" {
            if let destinationVC = segue.destination as? PlayerViewController {
                destinationVC.auth = self.auth
                destinationVC.session = self.session
                
                if !filteredSongs.isEmpty {
                    destinationVC.songList = filteredSongs
                }
                else if songs != nil {
                    destinationVC.songList = songs
                }
                destinationVC.currentSongPositionInList = self.currentSongPositionInList
            }
        }
        
        if segue.identifier == "loginSegue" {
            if let destinationVC = segue.destination as? LogInViewController {
                destinationVC.delegate = self
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "loginSegue":
            
            if logInButton.title == "Log out" {

                let currentOnlineUserReference = FIRDatabase.database().reference(withPath: "online users/\(self.userID!)")
                currentOnlineUserReference.removeValue()
                
                self.currentUser = nil
                logInButton.title = "Log in"
                
            return false} else {return true}
            
        default: return true
            
        }

    }
    
    // MARK: - LoginViewControllerDelegate methods
    
    func setUserID(_ id: String) {
        self.userID = id
    }
    
    func setUserReference(_ ref: FIRDatabaseReference) {
        self.userReference = ref
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



