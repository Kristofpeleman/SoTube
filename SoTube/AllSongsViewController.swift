//
//  AllSongsViewController.swift
//  SoTube
//
//  Created by VDAB Cursist on 09/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import AVFoundation


class AllSongsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
//    let feedURL = "https://api.spotify.com/v1/tracks/1zHlj4dQ8ZAtrayhuDDmkY?"
    let feedURLs = ViewModel().feeds
    let searchURL = "https://api.spotify.com/v1/search?query=Eminem&type=track&market=BE&offset=0&limit=50"
    
//    var song: Song?
    var currentSong: Song?
    var songs: [Song]?
    var audioPlayer: AVAudioPlayer?

    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    
//        setSongFromJSONFeed(json: feedURL)
        setSongsFromJSONFeed(jsonData: feedURLs)
    }
    
    override func viewDidAppear(_ animated: Bool) {

        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - TableView Datasource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (songs?.count) ?? 4
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongTableViewCell
        
        if let song = self.songs?[indexPath.row] {
        cell.artistNameLabel.text = getStringOfArtists(artists: (song.artistNames))
        cell.songTitleLabel.text = song.songTitle
        cell.costLabel.text = String(describing: song.cost)
        }
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentSong = self.songs?[indexPath.row]
        playSound(withURL: URL(string: (self.songs?[indexPath.row].previewURLAssString)!)!)
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
    
    func playSound(withURL url : URL) {
        do {
            try audioPlayer = AVAudioPlayer.init(data: Data(contentsOf: url), fileTypeHint: "mp3")

        }
        catch {print("assignment of audioplayer failed")}
        audioPlayer?.play()
    }
    
    
    func getStringOfArtists(artists: [String]) -> String {
        
        var fullListOfArtists = artists[0]
        if artists.count > 1 {
            for index in 1...artists.count - 1 {
                fullListOfArtists += " & \(artists[index])"
            }
        }
        
        return fullListOfArtists
    }
    
    
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
                    } else {self.songs = [Song(songTitle: songName, artistNames: allArtists, spotify_ID: spotify_ID, previewURLAssString: preview_url)] }
                    
                }
            }
            
            task.resume()
        }
        
    }

}
