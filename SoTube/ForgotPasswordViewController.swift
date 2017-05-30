//
//  ForgotPasswordViewController.swift
//  SoTube
//
//  Created by VDAB Cursist on 10/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var emailAddressTextField: UITextField!
    
    // MARK: - Standard Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - IBActions
    @IBAction func resetPassword(_ sender: UIButton) {
        
        // If the textfield is empty
        if emailAddressTextField.text == "" {
            // Create a UIAlertController
            let alertController = UIAlertController(title: "No Address",
                                                    message: "Please enter a valid email-address.",
                                                    preferredStyle: .alert
            )
            
            // Create a UIAlertAction
            let okAction = UIAlertAction(title: "Ok",
                                         style: .cancel,
                                         handler: nil
            )
            
            // Add alertAction to alertController
            alertController.addAction(okAction)
            
            // Show/Present the alertController
            self.present(alertController, animated: true, completion: nil)
        }
        // If it isn't empty
        else {
            // Call function to send an email with a link to reset your password for the given emailAddress
            sendResetPasswordMail()
        }
    }
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Dismiss keyboard
        self.view.endEditing(true)
        
        // Go back to the ViewController you were on before you came to ForgotPasswordViewController
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Homemade Functions
    func sendResetPasswordMail(){
        FIRAuth.auth()?.sendPasswordReset(withEmail: emailAddressTextField.text!, completion: { (error) in
            guard let _ = error else {
                // Dismiss keyboard
                self.view.endEditing(true)
                
                // Create a UIAlertController
                let alertController = UIAlertController(title: "Email sent",
                                                        message: "An email has been sent to you email-address to reset your password.",
                                                        preferredStyle: .alert
                )
                
                // Create a UIAlertAction
                let okAction = UIAlertAction(title: "Ok",
                                             style: .cancel,
                                             handler: { _ in
                                                // Go back to the ViewController you were on before you came to ForgotPasswordViewController
                                                self.dismiss(animated: true, completion: nil)
                })
                
                // Add alertAction to alertController
                alertController.addAction(okAction)
                
                // Show/Present the alertController
                self.present(alertController, animated: true, completion: nil)
                
                // End this function
                return
            }
            
            // Dismiss keyboard
            self.view.endEditing(true)
            
            // Create a UIAlertController
            let alertController = UIAlertController(title: "Failed to send",
                                                    message: "This account does not exist.",
                                                    preferredStyle: .alert
            )
            
            // Create a UIAlertAction
            let okAction = UIAlertAction(title: "Ok",
                                         style: .cancel,
                                         handler: nil
            )
            
            // Add alertAction to alertController
            alertController.addAction(okAction)
            
            // Show/Present the alertController
            self.present(alertController, animated: true, completion: nil)
            
        })
    }
    
    @IBAction func stopKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
    // MARK: - Homemade Functions
    
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -150 // Move view 150 points upward
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
    
    
}
