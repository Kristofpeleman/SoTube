//
//  AllSongsViewController.swift
//  SoTube
//
//  Created by VDAB Cursist on 09/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import AVFoundation




class AllSongsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UISearchBarDelegate {
    
//    let feedURL = "https://api.spotify.com/v1/tracks/1zHlj4dQ8ZAtrayhuDDmkY?"
    let feedURLs = ViewModel().feeds
    let searchURL = "https://api.spotify.com/v1/search?query=Eminem&type=track&market=BE&offset=0&limit=50"
    
    var currentSong: Song?
    var songs: [Song]? {
        didSet {
            if songs?.count == feedURLs.count {
                self.tableView.reloadData()
            }
        }
    }
    var audioPlayer: AVAudioPlayer?
    
    var filteredSongs: [Song] = []
    var currentPickerViewRow = 0
    
    
    

    @IBOutlet weak var sortingPickerView: UIPickerView!
    @IBOutlet var sortingOptions: SortingOptions!
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        sortingPickerView.dataSource = sortingOptions
        tableView.dataSource = self
        searchBar.delegate = self
//        setSongFromJSONFeed(json: feedURL)
        setSongsFromJSONFeed(jsonData: feedURLs)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if !filteredSongs.isEmpty {
            currentSong = self.filteredSongs[indexPath.row]
        }
        else {
            currentSong = self.songs?[indexPath.row]
        }
        //playSound(withURL: URL(string: (self.songs?[indexPath.row].previewURLAssString)!)!)
        performSegue(withIdentifier: "musicPlayerSegue", sender: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - Homemade Functions
    /*
    func playSound(withURL url : URL) {
        do {
            try audioPlayer = AVAudioPlayer.init(data: Data(contentsOf: url), fileTypeHint: "mp3")

        }
        catch {print("assignment of audioplayer failed")}
        audioPlayer?.play()
    }
    */
    
    func getStringOfArtists(artists: [String]) -> String {
        
        var fullListOfArtists = artists[0]
        if artists.count > 1 {
            for index in 1...artists.count - 1 {
                fullListOfArtists += " & \(artists[index])"
            }
        }
        return fullListOfArtists
    }
    
    
    func alterTableViewLabels(forSongList list: [Song], inCell cell: SongTableViewCell, atRow row: Int){
        cell.artistNameLabel.text = getStringOfArtists(artists: (list[row].artistNames))
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

    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sortingOptions.values[row]
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
            currentPickerViewRow = 0
        case "Artist (Z-A)":
            sortedList.sort(by: {$0.artistNames[0] > $1.artistNames[0]})
            currentPickerViewRow = 1
        case "Song Title (A-Z)":
            sortedList.sort(by: {$0.songTitle < $1.songTitle})
            currentPickerViewRow = 2
        case "Song Title (Z-A)":
            sortedList.sort(by: {$0.songTitle > $1.songTitle})
            currentPickerViewRow = 3
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
                    return song.artistNames[1].lowercased().contains(searchText.lowercased())
                }
                return false
            }))
            filteredSongs += songs!.filter(({ (song) -> Bool in
                return song.songTitle.lowercased().contains(searchText.lowercased())
            }))
            
        }
        pickerView(sortingPickerView, didSelectRow: currentPickerViewRow, inComponent: 0)
        tableView.reloadData()
    }
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "musicPlayerSegue" {
            if let destinationVC = segue.destination as? MusicPlayerViewController {
                destinationVC.currentSong = self.currentSong
            }
        }
    }
    
    
    
    
    
//    func setSongFromJSONFeed(json: String) {
//        
//        let request = URLRequest(url: URL(string: json)!)
//        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
//        let task = session.dataTask(with: request) {
//            data, response, error in
//            if let jsonData = data,
//                let feed = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)) as? NSDictionary,
//                let songName = feed.value(forKeyPath: "name") as? String,
//                let artists = feed.value(forKeyPath: "artists") as? NSArray,
//                let spotify_ID = feed.value(forKeyPath: "id") as? String,
//                let preview_url = feed.value(forKeyPath: "preview_url") as? String
//            {
//                var allArtists: [String] = []
//                for dictionary in artists {
//                    allArtists.append((dictionary as! NSDictionary).value(forKey: "name") as! String? ?? "NOT FOUND")
//                }
//                
//                self.song = Song(songTitle: songName, artistNames: allArtists, spotify_ID: spotify_ID, previewURLAssString: preview_url)
//                
//            }
//        }
//        
//        task.resume()
    //
    //    }
    
    // MARK: - JSON
    
    func setSongsFromJSONFeed(jsonData: [String]) {
        
        for json in jsonData {
            
            let request = URLRequest(url: URL(string: json)!)
            let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
            let task = session.dataTask(with: request) {
                data, response, error in
                if let jsonData = data,
                    let feed = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)) as? NSDictionary,
                    let songName = feed.value(forKeyPath: "name") as? String,
                    let artists = feed.value(forKeyPath: "artists") as? NSArray,
                    let spotify_ID = feed.value(forKeyPath: "id") as? String,
                    let preview_url = feed.value(forKeyPath: "preview_url") as? String
                {
                    var allArtists: [String] = []
                    for dictionary in artists {
                        allArtists.append((dictionary as! NSDictionary).value(forKey: "name") as! String? ?? "NOT FOUND")
                        
                        
                    }
                if let _ = self.songs {
                    self.songs?.append(Song(songTitle: songName, artistNames: allArtists, spotify_ID: spotify_ID, previewURLAssString: preview_url))
                } else {
                    self.songs = [Song(songTitle: songName, artistNames: allArtists, spotify_ID: spotify_ID, previewURLAssString: preview_url)]
                }
                    
                }
            }
            
            
            task.resume()
        }
        
    }
}


