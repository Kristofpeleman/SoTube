//
//  AllSongsViewController.swift
//  SoTube
//
//  Created by VDAB Cursist on 09/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit

class AllSongsViewController: UIViewController {
    
    let feedURL = "https://api.spotify.com/v1/tracks/1zHlj4dQ8ZAtrayhuDDmkY?"

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
//                print(allArtists.reduce("", {$0 + " " + $1}))
                print(preview_url)
                
//                self.titleLabel.text = title
//                self.artistLabel.text = artist
//                let _ = self.loadImage(from: URL(string: imagePathArray.lastObject! as! String)!)
                
            }
        }
        task.resume()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func getStringOfArtists(artists: [String]) -> String {
        
        
        return ""
    }

}
