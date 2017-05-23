//
//  MySongsViewController.swift
//  SoTube
//
//  Created by VDAB Cursist on 09/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import Firebase

class MySongsViewController: TopMediaViewController {
    
    var currentUser: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        print(auth ?? "AUTH is nil")
        print(session ?? "SESSION is nil")
        print(rootReference ?? "ROOT is nil")
        
//        let mainTabBarController:UITabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
//        
//        for vc in mainTabBarController.childViewControllers {
//            if let user = (vc as! TopMediaViewController).user {
//                self.user = user
//            }
//        }
//        
//        print(self.user ?? "NO FIRUser")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(FIRAuth.auth()?.currentUser ?? "NO FIRUser")
        print(FIRAuth.auth()?.currentUser?.displayName ?? "NO FIRUser displayName")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(currentUser ?? "NO CURRENT USER SET")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "loginSegue" {
            if let _ = segue.destination as? LogInViewController {
                
            }
        }
        
    }
    

}
