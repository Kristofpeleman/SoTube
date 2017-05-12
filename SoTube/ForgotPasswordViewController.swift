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
    
    
    @IBOutlet weak var resetPasswordImageView: UIImageView!
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    @IBAction func resetPassword(_ sender: UIButton) {
        
        
        if emailAddressTextField.text == "" {
            let alertController = UIAlertController(title: "No Address", message: "Please enter a valid email-address.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            sendResetPasswordMail()
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func sendResetPasswordMail(){
        FIRAuth.auth()?.sendPasswordReset(withEmail: emailAddressTextField.text!, completion: { (error) in
            guard let _ = error else {
                // Dismiss keyboard
                self.view.endEditing(true)
                
                let alertController = UIAlertController(title: "Email sent", message: "An email has been sent to you email-address to reset your password.", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: { _ in self.dismiss(animated: true, completion: nil)})
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            // Dismiss keyboard
            self.view.endEditing(true)
            
            
            let alertController = UIAlertController(title: "Failed to send", message: "This account does not exist.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        })
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
