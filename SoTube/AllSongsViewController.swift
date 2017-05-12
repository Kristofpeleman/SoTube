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
    
    let feedURL = "https://api.spotify.com/v1/tracks/1zHlj4dQ8ZAtrayhuDDmkY?"
    
    var songTitle: String?
    var artistName: String?
    var audioPlayer: AVAudioPlayer?
    var url: URL?
    
    
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Im here!")
        
        let request = URLRequest(url: URL(string: feedURL)!)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        let task = session.dataTask(with: request) {
            data, response, error in
            if let jsonData = data,
                let feed = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)) as? NSDictionary,
                let songName = feed.value(forKeyPath: "name") as? String,
                let artists = feed.value(forKeyPath: "artists") as? NSArray,
                let preview_url = feed.value(forKeyPath: "preview_url") as? String
            {
                print(songName)
                
                var allArtists: [String] = []
                for dictionary in artists {
                    allArtists.append((dictionary as! NSDictionary).value(forKey: "name") as! String? ?? "NOT FOUND")
                }
                print(allArtists[0])
                print(allArtists[1])
                print(preview_url)
                
                self.songTitle = songName
                self.artistName = self.getStringOfArtists(artists: allArtists)
                self.url = URL(string: preview_url)
                
            }
        }
        task.resume()
        
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongTableViewCell
        
        cell.artistNameLabel.text = songTitle
        cell.songTitleLabel.text = artistName
        cell.costLabel.text = "2.0$"
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playSound(withURL: self.url!)
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

}
