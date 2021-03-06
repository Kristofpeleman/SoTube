//
//  ShoppingCartViewController.swift
//  SoTube
//
//  Created by Kristof Peleman on 22/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import Firebase

class ShoppingCartViewController: TopMediaViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Global Variables
    // Variables to access spotify database and our Firebase
//    var auth: SPTAuth?
//    var session: SPTSession?
    var userReference: FIRDatabaseReference?
    
    var shared = Shared.current
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var availablePointsLabel: UILabel!
    
    @IBOutlet weak var buySongsButton: UIButton!
    @IBOutlet weak var emptyShoppingCartButton: UIBarButtonItem!
    
    //MARK: - UIViewController Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.shared.user = Shared.current.user
        // Hides the standard navigationBar (our custom bar will still show)
        navigationController?.isNavigationBarHidden = true
        
        print(shared.user?.shoppingCart?[0] ?? "NO SONG IN SHOPPING CART")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.songVCBackGroundImage.image = UIImage(named: Shared.current.backGroundImage)
        
        
    }
    
    
    // When the view has appeared
    override func viewDidAppear(_ animated: Bool) {
        
        self.shared.user = Shared.current.user
        
        // Reload the tableView's design and cells
        self.tableView.reloadData()
        
        // Update the pointsLabel
        updatePointLabels()
        
        if shared.user == nil {
            buySongsButton.isEnabled = false
            self.availablePointsLabel.text = "0"
        }
        else {
            buySongsButton.isEnabled = true
        }
        
        enableOfDisableTrashButton()
    }
    
    
    func enableOfDisableTrashButton(){
        if shared.user?.shoppingCart != nil {
            emptyShoppingCartButton.isEnabled = true
        }
        else {
            emptyShoppingCartButton.isEnabled = false
        }
    }
    
    
    // MARK: - IBActions
    
    // Function to buy the songs in our shoppingCart
    @IBAction func buySongs(_ sender: UIButton) {
        
        // Check if we have a shared.user and if that shared.user has a shoppingCart
        if let _ = self.shared.user?.shoppingCart {
            
            // Can't use a funciton-call in an "if"-statement during calculations, so created a constant containing the calculation
            let newPoints = self.shared.user!.points - calculatePoints()
            
            // If our new point-total would be lower than 0
            if newPoints < 0 {
                // Created the design and contents of the alert
                let alertController = UIAlertController(title: "Insufficient Points", message: "You do not have enough points to buy these songs.\nWould you like to buy 20 more points?", preferredStyle: .alert)
                
                // Create a UIAlertAction (which reacts like a button, but will always make the alert disappear after pressing)
                let addPointsAction = UIAlertAction(title: "Buy",
                                                    style: .default,
                                                    // "handler" defines what has to happen when we press it, but it needs "(action) in" as first part (unless we input nil, but then it won't do anything)
                                                    handler: { (action) in
                                                        
                                                        // Add 20 points to the shared.user's points-total
                                                        self.shared.user?.points += 20
                                                        
                                                        self.updatePointLabels()
                                                        
                                                        // Make a reference from our firebase's shared.user's points-total
                                                        let userShoppingCartReference = self.userReference?.child("points")
                    
                                                        // Use the reference to give a new value to that part of our firebase (e.g.: we had 4 points in firebase, but 16 in shared.user.points --> our firebase is now 16 aswell)
                                                        userShoppingCartReference?.setValue(self.shared.user?.points)
                })
                
                // Create another UIAlertAction
                let cancelAction = UIAlertAction(title: "Cancel",
                                                 style: .cancel,
                                                 // Note how this action does nothing when pressed, except make the alert disappear
                                                 handler: nil)
                
                // Add our 2 new actions to our alertController
                alertController.addAction(cancelAction)
                alertController.addAction(addPointsAction)
                
                // Show/Present our alert
                present(alertController, animated: true, completion: nil)
            }
            
            // If our new points-total is bigger than 0
            else {
                
                // Adapt "points"
                // Lower our shared.user.points by the total cost of all the songs in the shoppingCart
                self.shared.user!.points -= calculatePoints()
                
                // Create a constant for easier access to said points
                let points = self.shared.user!.points
                
                // Make a reference from our firebase's shared.user's points-total
                let pointsReference = userReference?.child("points")
                // Change the value of where our reference points in our firebase
                pointsReference?.setValue(points)
                
                // Adapt "mySongs"
                
                // Create a constant for easier access to the songs in our shoppingCart
                let songs = self.shared.user!.shoppingCart!
                

                
                // Add the songs from our shoppingCart to shared.user.mySongs
                self.shared.user?.addToMySongs(songs)
                
                // Make a reference from our firebase's shared.user's "mySongs"
                let userMySongsReference = self.userReference?.child("mySongs")
                
                // For each number between 1 and the total amount in our shoppingCart (if it's 0 we won't have a shoppingCart (see first "if"-statement in this funcition) and if there is only 1, then it will perform our "for" once.
                for index in 1...songs.count {
                    
                    // Make a reference for something that is inside our already existing reference
                    let songInMySongsReference = userMySongsReference?.child(songs[index - 1].spotify_ID!)
                    // Change the value of where our new reference points in our firebase
                    songInMySongsReference?.setValue(returnDictionaryFor(songs[index - 1]))
                }
                
                // Nested Helper function for the filter closure above
                func songIsInWishList(_ song: Song) -> Bool {
                    return self.shared.user!.wishList!.contains(where: {song.spotify_ID == $0.spotify_ID})
                }
                
                // Check for existence of purchased songs in Wishlist and remove them from Firebase wishList
                if let _ = self.shared.user?.wishList {
                    let wishListSongIDs = songs.filter{songIsInWishList($0)}.map{$0.spotify_ID}
                    let userWishListReference = self.userReference?.child("wishList")
                    
                    if wishListSongIDs.count > 0 {
                        
                        for i in 1...wishListSongIDs.count {
                            
                            var locationInWishList: Int?
                            
                            for index in 1...Shared.current.user!.wishList!.count {
                                if Shared.current.user!.wishList![index - 1].spotify_ID == wishListSongIDs[i - 1] {
                                    locationInWishList = index - 1
                                }
                            }
                            
                            Shared.current.user!.wishList!.remove(at: locationInWishList!)
                            
                            
                            let songInWishListReference = userWishListReference?.child(wishListSongIDs[i - 1]!)
                            songInWishListReference?.removeValue()
                            
                        }
                    }
                }
                


                
                // Adapt ShoppingCart
                
                // Make a reference from our firebase's shared.user's shoppiongCart
                let shoppingCartReference = userReference?.child("shoppingCart")
                // Remove shoppingCart from our firebase
                shoppingCartReference?.removeValue()
                
                // Remove our shoppingCart in our shared.user/give it "nil" as value
                self.shared.user?.shoppingCart = nil
                
                // Reload our tableView
                self.tableView.reloadData()
                
                // Go back to the ViewController you were in before you came to this one
//                self.dismiss(animated: true, completion: nil)
            }
        }
        updatePointLabels()
    }
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Go back to the ViewController you were in before you came to this one
        dismiss(animated: true, completion: nil)
    }
    
    // Button to remove everything in your shoppingCart without purchasing anything
    @IBAction func emptyShoppingCart(_ sender: UIBarButtonItem) {
        
        // Create a UIAlertAction
        let alertController = UIAlertController(title: "Empty Cart?", message: "Are you certain you want to remove all the songs from your shopping cart?", preferredStyle: .alert)
        
        // Create a UIAlertAction
        let removeAction = UIAlertAction(title: "Yes",
                                         // Note how "style" is ".destructive", this makes the text red to show the person using the app that we will be removing something
                                         style: .destructive,
                                         handler: { (action) in
                                            
                                            // Remove shared.user.shoppingCart/give it value "nil"
                                            self.shared.user?.shoppingCart = nil
                                            Shared.current.user?.shoppingCart = nil
            
                                            // Create a reference tou the shoppingCart in our firebase
                                            let userShoppingCartReference = self.userReference?.child("shoppingCart")
            
                                            // Remove the shoppingCart in our firebase
                                            userShoppingCartReference?.removeValue()
                                            
                                            // Go back to the ViewController you were in before you came to this one
//                                            self.dismiss(animated: true, completion: nil)
                                            self.tableView.reloadData()
                                            self.updatePointLabels()
        })
        
        // Create a UIAlertAction that does nothing but make the alert go away
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        
        // Add our 2 actions to our alert
        alertController.addAction(cancelAction)
        alertController.addAction(removeAction)
        
        // Show/Present our alert
        present(alertController, animated: true, completion: nil)
        
        updatePointLabels()
    }
    
    
    
    // MARK: - TableView Datasource Methods
    // Defines the amount of rows in our tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If there is a shared.user and a shoppingCart for said user
        if let _ = shared.user?.shoppingCart {
            // Use the amount of items in our shoppingCart
            return (shared.user?.shoppingCart?.count)!
        }
        // Otherwise there are 0 rows (we could have used an "else", but since our "if" has a "return" this wasn't needed)
        return 0
        
    }
    
    // Define the contents of our tableView's cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongTableViewCell
        
        // The cell's songTitleLabel, artistNameLabel and costLabel are defined by the item in our shoppingCart that is in the same position as the number of row we are on in our tableView (e.g.: row 5 --> item 5 in shoppingCart; row 2 --> item 2)
        
        cell.songTitleLabel.text = shared.user!.shoppingCart![indexPath.row].songTitle
        cell.artistNameLabel.text = shared.user!.shoppingCart![indexPath.row].artists
        cell.costLabel.text = String(describing: shared.user!.shoppingCart![indexPath.row].cost)
        
        // NOTE: AMOUNT of rows starts at 1, but when USING/CALLING a row it starts at 0 (just like an array/dictionary
        
        
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let song = shared.user!.shoppingCart![indexPath.row]
            let userShoppingCartReference = self.userReference?.child("shoppingCart")
            userShoppingCartReference?.child(song.spotify_ID!).removeValue()
            
            self.shared.user?.shoppingCart = shared.user?.shoppingCart?.filter{$0.spotify_ID != song.spotify_ID}
            self.tableView.reloadData()
            updatePointLabels()
            
            if shared.user!.shoppingCart!.isEmpty {
                shared.user?.shoppingCart = nil
            }
            enableOfDisableTrashButton()
        }
    }
    
    // MARK: - Homemade Functions
    
    // Function returning an Integer
    func calculatePoints() -> Int {
        // If we have a shared.user and (s)he has a shoppingCart (has shoppingCart if shoppingCart's value isn't nil)
        if let _ = self.shared.user?.shoppingCart {
            // The amount of items in our shoppingCart multiplied by 2 (cost per song is always 2)
            let total = self.shared.user!.shoppingCart!.count * 2
            return total
        }
        
        // Else return 0 (no "else" typed because of teh "return" in our "if")
        return 0
        
        
        
        
        // ALTERNATIVE for our "if"-statement in case songs' cost aren't always 2 in the future
        /*
        if let shoppingCart = self.shared.user?.shoppingCart {
            var total = 0
            for song in shoppingCart {
                total += song.cost
            }
            return total
        }
         
         // Down-side: for-loop
         // Up-side: Different costs are supported
        */
    }
    
    
    // Function returning a dictionary of [String : Any], using a parameter of type "Song"
    func returnDictionaryFor(_ song: Song) -> [String : Any] {
        
        // "String" = key; "Any" = value
        let dict: [String : Any] = [
            "spotify_ID" : song.spotify_ID!,
            "songTitle" : song.songTitle,
            "json" : song.spotifyJSONFeed,
            "artists" : song.artists,
            "previewURL" : song.previewURLAssString,
            "imageURL" : song.imageURLAssString,
            "duration" : song.duration,
            "favorite" : song.favorite
        ]
        
        return dict
    }
    
    
    func updatePointLabels(){
        if shared.user != nil {
            self.pointsLabel.text = "Cost: \(calculatePoints()) Points"
            self.availablePointsLabel.text = "Your points: \(shared.user!.points)"
        }
    }
    
    
}
