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
        
    }
    
    
    // MARK: - TableView Datasource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (currentUser?.shoppingCart?.count)!
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
    

}
