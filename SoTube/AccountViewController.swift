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
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var loginButton: UIBarButtonItem!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailAddressLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    
    // MARK: - UIViewController functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = self.shared.user {
            self.userNameLabel.text = shared.user?.userName
            self.emailAddressLabel.text = shared.user?.emailAddress
            self.pointsLabel.text = "\(shared.user!.points)"
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(FIRAuth.auth()?.currentUser ?? "NO FIRUser")
        print(FIRAuth.auth()?.currentUser?.displayName ?? "NO FIRUser displayName")
        
        if let _ = shared.user {
            loginButton.title = "Log out"
            
            self.userNameLabel.text = shared.user?.userName
            self.emailAddressLabel.text = shared.user?.emailAddress
            self.pointsLabel.text = "\(shared.user!.points)"
            
            print(self.shared.user?.fireBaseID ?? "NO FIREBASE ID")
            print(self.shared.user?.userName ?? "NO USERNAME")
            print(self.shared.user?.emailAddress ?? "NO EMAIL")
            print(self.shared.user?.points ?? "NO POINTS")
            
        } else {
            loginButton.title = "Log in"
            self.userNameLabel.text = "NO USER"
            self.emailAddressLabel.text = "NO USER"
            self.pointsLabel.text = "NO USER"
            
            let alertController = UIAlertController(title: "No User found", message: "You need to log in before you can see your account details", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
        
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "loginSegue" {
            if let destinationVC = segue.destination as? LogInViewController {
                destinationVC.delegate = self
            }
        }
        
    }
    
    // An override function when performing a segue
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        // Check the value of "identifier"
        switch identifier {
        // If the value is "loginSegue"
        case "loginSegue":
            // If "logInButton"'s title is "Log out"
            if loginButton.title == "Log out" {
                
                // Get the user that is logged in his/her online-status from FireBase
                let currentOnlineUserReference = FIRDatabase.database().reference(withPath: "online users/\(self.shared.user!.fireBaseID)")
                // Remove the value of the online-status (make it go offline)
                currentOnlineUserReference.removeValue()
                
                // Since the value isn't in FireBase anymore, we must delete it localy
                self.shared.user = nil

                // Change "logInButton"'s title to "Log in"
                loginButton.title = "Log in"
                self.userNameLabel.text = "NO USER"
                self.emailAddressLabel.text = "NO USER"
                self.pointsLabel.text = "NO USER"
                
                // Leave the function with the return and don't perform the segue
                return false
            }
                // If "logInButton"'s title isn't "Log out"
            else {
                // Perform the segue
                return true
            }
        // If the identifier's value isn't any of the above: perform Segue
        default: return true
        }
    }
 
    
    
    // MARK: - LoginViewControllerDelegate methods
    
    func setUser(_ user: User) {
        self.shared.user = user
    }

}
