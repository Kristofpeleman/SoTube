//
//  TopMediaViewController.swift
//  SoTube
//
//  Created by Kristof Peleman on 16/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import Firebase

class TopMediaViewController: UIViewController {
    
    // GLobal variables
    
    var auth: SPTAuth?
    var session: SPTSession?
    var rootReference: FIRDatabaseReference?
    
    
    // IBOutlets
    
    @IBOutlet weak var songVCBackGroundImage: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.songVCBackGroundImage.image = UIImage(data: try! Data(contentsOf: URL(string: "https://i.scdn.co/image/2e5e772e7cec065be0a59891d69ea39efd6c3031")!))
        // Do any additional setup after loading the view.
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

}
