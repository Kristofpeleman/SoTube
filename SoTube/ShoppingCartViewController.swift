//
//  ShoppingCartViewController.swift
//  SoTube
//
//  Created by Kristof Peleman on 22/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import Firebase

class ShoppingCartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Global Variables
    var auth: SPTAuth?
    var session: SPTSession?
    var currentUser: User?
    var userReference: FIRDatabaseReference?
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pointsLabel: UILabel!
    
    
    //MARK: - UIViewController Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true
        
        print(currentUser?.shoppingCart?[0] ?? "NO SONG IN SHOPPING CART")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
        self.pointsLabel.text = "Cost: \(calculatePoints()) Points"
    }
    
    
    // MARK: - IBActions
    
    @IBAction func buySongs(_ sender: UIButton) {
        if let _ = self.currentUser?.shoppingCart {
            
            // Adapt "mySongs"
            
            // Adapt "points"
            
            let newPoints = self.currentUser!.points - calculatePoints()
            
            if newPoints < 0 {
                let alertController = UIAlertController(title: "Insufficient Points", message: "You do not have enough points to buy these songs.\nWould you like to buy 20 more points?", preferredStyle: .alert)
                let addPointsAction = UIAlertAction(title: "Buy", style: .default, handler: { (action) in
                    
                    self.currentUser?.points += 20
                    
                    let userShoppingCartReference = self.userReference?.child("points")
                    
                    userShoppingCartReference?.setValue(self.currentUser?.points)
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                alertController.addAction(addPointsAction)
                present(alertController, animated: true, completion: nil)
                
            }
                
            else {
                self.currentUser!.points -= calculatePoints()
                let points = self.currentUser!.points
                let pointsReference = userReference?.child("points")
                pointsReference?.setValue(points - calculatePoints())
                
                self.currentUser?.addToMySongs(self.currentUser!.shoppingCart!)
                
                let userMySongsReference = self.userReference?.child("mySongs")
                let songs = self.currentUser!.shoppingCart!
                
                for index in 1...songs.count {
                    let songInMySongsReference = userMySongsReference?.childByAutoId()
                    songInMySongsReference?.setValue(returnDictionaryFor(songs[index - 1]))
                }

                
                // Adapt ShoppingCart
                let shoppingCartReference = userReference?.child("shoppingCart")
                shoppingCartReference?.removeValue()
                
                self.currentUser?.shoppingCart = nil
                self.tableView.reloadData()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func emptyShoppingCart(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Empty Cart", message: "Are you certain you want to remove all the songs from your shopping cart?", preferredStyle: .alert)
        let removeAction = UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            
            self.currentUser?.shoppingCart = nil
            
            let userShoppingCartReference = self.userReference?.child("shoppingCart")
            
            userShoppingCartReference?.removeValue()

            
            self.dismiss(animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(removeAction)
        present(alertController, animated: true, completion: nil)
        
        
    }
    
    
    
    // MARK: - TableView Datasource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = currentUser?.shoppingCart {
            return (currentUser?.shoppingCart?.count)!
        } else {return 0}
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongTableViewCell
        cell.songTitleLabel.text = currentUser!.shoppingCart![indexPath.row].songTitle
        cell.artistNameLabel.text = currentUser!.shoppingCart![indexPath.row].artists
        cell.costLabel.text = String(describing: currentUser!.shoppingCart![indexPath.row].cost)
        
        return cell
    }
    
    // MARK: - Homemade Functions
    
    func calculatePoints() -> Int {
        if let _ = self.currentUser?.shoppingCart {
            let total = self.currentUser!.shoppingCart!.count * 2
            return total
        } else {return 0}
    }
    
    func returnDictionaryFor(_ song: Song) -> [String : Any] {
        let dict: [String : Any] = [
            "spotify_ID" : song.spotify_ID!,
            "songTitle" : song.songTitle,
            "json" : song.spotifyJSONFeed,
            "artists" : song.artists,
            "previewURL" : song.previewURLAssString,
            "imageURL" : song.imageURLAssString,
            "duration" : song.duration,
        ]
        return dict
    }
    
}
