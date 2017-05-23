//
//  LogInViewController.swift
//  SoTube
//
//  Created by VDAB Cursist on 10/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import Firebase


protocol LoginViewControllerDelegate {
    func setUserReference(_ ref: FIRDatabaseReference)
    func setUserID(_ id: String)
}

class LogInViewController: UIViewController {
    
    // MARK: - IBOutlets

    @IBOutlet weak var loginImageView: UIImageView!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Constants and variables
    
    private var onlineUsersReference: FIRDatabaseReference?
    var delegate: LoginViewControllerDelegate?
    
    let activityIndicator = UIActivityIndicatorView()
    
    // MARK: UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting the online users reference
        onlineUsersReference = FIRDatabase.database().reference(withPath: "online users")
        emailAddressTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
        
        
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color? = .black
        activityIndicator.center = self.view.center
        view.addSubview(activityIndicator)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - IBActions
    
    @IBAction func login(_ sender: UIButton) {
        
        self.activityIndicator.startAnimating()
        
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
            
            FIRAuth.auth()?.addStateDidChangeListener({[weak self] (auth, user) in
                if let currentUser = user {
                    let currentUserReference = self?.onlineUsersReference?.child(currentUser.uid)
                    currentUserReference?.setValue(currentUser.displayName)
                    currentUserReference?.onDisconnectRemoveValue()
                }
            })
            

            
            
            // Update FireBase Users IN CASE OF A NEW USER
            
            let existingUsersReference = FIRDatabase.database().reference(withPath: "Users")
            
            existingUsersReference.observe(.value, with: {snapshot in

                if !snapshot.hasChild(currentUser.uid) {
                    
                    let user: [String : Any] = ["userName": currentUser.displayName!, "emailAddress": currentUser.email!, "points": 20]
                    let thisUserReference = existingUsersReference.child("\(currentUser.uid)")
                    thisUserReference.setValue(user)
                }
            })
            
            sleep(2)
            
            // Setting userID and userReference in the delegate
            
            let thisUserReference = existingUsersReference.child("\(currentUser.uid)")
            
            self.delegate?.setUserID(currentUser.uid)
            self.delegate?.setUserReference(thisUserReference)
            
            

            
            // Dismiss keyboard
            self.view.endEditing(true)
            
            self.activityIndicator.stopAnimating()
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
