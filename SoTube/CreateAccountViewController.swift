//
//  CreateAccountViewController.swift
//  SoTube
//
//  Created by VDAB Cursist on 10/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordControlTextField: UITextField!
    
    
    // MARK: - Standard Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - IBActions
    @IBAction func createAccount(_ sender: UIButton) {
        // If both passwordTextFields are the same (to prevent mistyping your own password when creating account)
        if passwordTextField.text == passwordControlTextField.text {
            
            // Check if any of the textFields is empty (excl. passwordControl seeing as it already has to be the same as password (which will be checked on being empty))
            guard let userName = userNameTextField.text,
                userName != "",
                let emailAddress = emailAddressTextField.text,
                emailAddress != "",
                let password = passwordTextField.text,
                password != ""
                // If one of them is empty
                else {
                    
                    // Create a UIAlertController
                    let alertController = UIAlertController(title: "Insufficient information",
                                                            message: "You must fill out all the fields to complete the registration successfully.",
                                                            preferredStyle: .alert
                    )
                    
                    // Create a UIAlertAction
                    let okAction = UIAlertAction(title: "OK",
                                                 style: .cancel,
                                                 handler: nil
                    )
                    
                    // Add alertAction to alertController
                    alertController.addAction(okAction)
                    
                    // Show/Present the alertController
                    self.present(alertController, animated: true, completion: nil)
                    
                    // End the function
                    return
            }
            
            
            // Register the user account on Firebase
            FIRAuth.auth()?.createUser(withEmail: emailAddress, password: password, completion: { (user, error) in
                // If something went wrong
                if let error = error {
                    
                    // Create a UIAlertController
                    let alertController = UIAlertController(title: "Registration error",
                                                            message: error.localizedDescription,
                                                            preferredStyle: .alert
                    )
                    
                    // Create a UIAlertAction
                    let okayAction = UIAlertAction(title: "OK",
                                                   style: .cancel,
                                                   handler: nil
                    )
                    
                    // Add alertAction to alertController
                    alertController.addAction(okayAction)
                    
                    // Show/Present the alertController
                    self.present(alertController, animated: true, completion: nil)
                    
                    // End the function
                    return
                }
                
                // Save the name of the user
                if let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest() {
                    changeRequest.displayName = userName
                    changeRequest.commitChanges(completion: { (error) in
                        if let error = error {
                            print("Failed to change the display name: \(error.localizedDescription)")
                        }
                    })
                }
                
                // Dismiss the keyboard
                self.view.endEditing(true)
                
                
                
                
                // Send Verification email
                user?.sendEmailVerification(completion: nil)
                
                // Create a UIAlertController
                let alertController = UIAlertController(title: "Email Verification",
                                                        message: "We've just sent a confirmation email to your email address. Please check your inbox and click the verification link in that email to complete registration.",
                                                        preferredStyle: .alert
                )
                
                // Create a UIAlertAction
                let okayAction = UIAlertAction(title: "OK",
                                               style: .cancel,
                                               handler: { (action) in
                                                // Go back to the ViewController you were on before you came to CreateAccountViewController
                                                self.dismiss(animated: true, completion: nil)
                })
                
                // Add alertAction to alertController
                alertController.addAction(okayAction)
                
                // Show/Present the alertController
                self.present(alertController, animated: true, completion: nil)
            })
        }
        
            // If the passwordTextFields don't have the same content
        else {
            
            // Create a UIAlertController
            let alertController = UIAlertController(title: "Password Control",
                                                    message: "Your passwords don't match. Please re-enter both password textfields.",
                                                    preferredStyle: .alert
            )
            
            // Create a UIAlertAction
            let okayAction = UIAlertAction(title: "OK",
                                           style: .cancel,
                                           handler: nil
            )
            
            // Call function to empty passwordTextFields
            updatePasswordTextFields()
            
            // Add alertAction to alertController
            alertController.addAction(okayAction)
            
            // Show/Present the alertController
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Go back to the ViewController you were on before you came to CreateAccountViewController
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Homemade Functions
    
    // Function to empty the passwordTextFields
    private func updatePasswordTextFields(){
        passwordTextField.text = ""
        passwordControlTextField.text = ""
    }
    
    // Function to empty all textFields
    private func updateView(){
        userNameTextField.text = ""
        emailAddressTextField.text = ""
        updatePasswordTextFields()
    }
    
    
}
