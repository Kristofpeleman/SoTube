//
//  AccountViewController.swift
//  SoTube
//
//  Created by Kristof Peleman on 26/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: TopMediaViewController, LoginViewControllerDelegate {
    
    // MARK: - Global variables and constants
    
    var shared = Shared.current

    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    
    // MARK: - LoginViewControllerDelegate methods
    
    func setUser(_ user: User) {
        self.shared.user = user
    }

}
