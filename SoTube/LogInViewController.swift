//
//  LogInViewController.swift
//  SoTube
//
//  Created by VDAB Cursist on 10/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import Firebase


class LogInViewController: UIViewController {
    
    // MARK: - IBOutlets

    @IBOutlet weak var loginImageView: UIImageView!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Constants and variables
    
    
    // MARK: UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailAddressTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - IBActions
    
    @IBAction func login(_ sender: UIButton) {
        guard let emailAddress = emailAddressTextField.text, emailAddress != "",
            let password = passwordTextField.text, password != "" else {
                
                let alertController = UIAlertController(title: "Login Error", message: "Both fields must not be blank.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
                
                return
        }
        
        
        FIRAuth.auth()?.signIn(withEmail: emailAddress, password: password, completion: { (user, error) in
            if let error = error {
                let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            
            // Verify email address
            guard let currentUser = user, currentUser.isEmailVerified else {
                let alertController = UIAlertController(title: "Email address not confirmed", message: "You haven't confirmed your email address yet. We sent you a confirmation email upon registration. You can click the verification link in that email. If you lost that email we'll gladly send you a new confirmation email. In that case you ought to tap Resend confirmation email.", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Resend email", style: .default, handler: { (action) in
                    user?.sendEmailVerification(completion: nil)
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            // Update FireBase Online Users
            
            let onlineUsersReference = FIRDatabase.database().reference(withPath: "online users")
            onlineUsersReference.setValue([currentUser.displayName! : currentUser.email])
            onlineUsersReference.onDisconnectRemoveValue()
            
            
            // Update FireBase Users IN CASE OF A NEW USER
            
            let existingUsersReference = FIRDatabase.database().reference(withPath: "Users")
            
            existingUsersReference.observe(.value, with: {snapshot in

                if !snapshot.hasChild(currentUser.displayName!) {
                    
                    let user: [String : Any] = ["userName": currentUser.displayName!, "emailAddress": currentUser.email!, "points": 20]
                    existingUsersReference.setValue([currentUser.displayName! : user])
                }
            })
            

            
            
            
            
            // Dismiss keyboard
            self.view.endEditing(true)
            
            self.dismiss(animated: true, completion: nil)
        })
        
        
    }
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Homemade Functions
    
    private func updateView(){
        emailAddressTextField.text = ""
        passwordTextField.text = ""
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "createAccountSegue"{
            updateView()
        }
        
        if segue.identifier == "forgotPasswordSegue"{
            updateView()
        }
    }


}
