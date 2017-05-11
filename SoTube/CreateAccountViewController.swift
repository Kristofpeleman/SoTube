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
    
    @IBOutlet weak var createAccountImageView: UIImageView!
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var passwordControlTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createAccount(_ sender: UIButton) {
        if passwordTextField.text == passwordControlTextField.text {
            guard let userName = userNameTextField.text, userName != "", let emailAddress = emailAddressTextField.text, emailAddress != "",
                let password = passwordTextField.text, password != "",
                let passwordControl = passwordControlTextField.text, passwordControl != "" else {
                    let alertController = UIAlertController(title: "Insufficient information", message: "You must fill out all the fields to complete the registration successfully.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
            }
            
            
            // Register the user account on Firebase
            FIRAuth.auth()?.createUser(withEmail: emailAddress, password: password, completion: { (user, error) in
                if let error = error {
                    let alertController = UIAlertController(title: "Registration error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
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
                
                let alertController = UIAlertController(title: "Email Verification", message: "We've just sent a confirmation email to your email address. Please check your inbox and click the verification link in that email to complete registration.", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                    // Dismiss the current view controller
                    self.dismiss(animated: true, completion: nil)
                })
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                
                
            })
        }
        else {
            let alertController = UIAlertController(title: "Password Control", message: "Your passwords don't match. Please re-enter both password textfields.", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            updatePasswordTextFields()
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    private func updatePasswordTextFields(){
        passwordTextField.text = ""
        passwordControlTextField.text = ""
    }
    
    private func updateView(){
        userNameTextField.text = ""
        emailAddressTextField.text = ""
        updatePasswordTextFields()
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
