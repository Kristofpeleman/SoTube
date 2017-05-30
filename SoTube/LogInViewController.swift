//
//  LogInViewController.swift
//  SoTube
//
//  Created by VDAB Cursist on 10/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import Firebase

// Created a protocol for a delegate
protocol LoginViewControllerDelegate {
    // Functions that will be needed to follow this protocol

    func setUser(_ user: User)
}


class LogInViewController: UIViewController {
    
    // MARK: - IBOutlets
    // Concerning Images
    @IBOutlet weak var imageSuperiorView: UIView!
    @IBOutlet weak var iconTopImageView: UIImageView!
    @IBOutlet weak var iconBottomImageView: UIImageView!
    
    // TextFields
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    // MARK: - Constants and variables
    
    // Variable to later update online users in our database
    private var onlineUsersReference: FIRDatabaseReference?
    
    // Create an optional variable that contains either "nil" or something corresponding with our "LoginViewControllerDelegate"-protocol
    var delegate: LoginViewControllerDelegate?
    
    // Created a variable that contains a UIActivityIndicatorView
    let activityIndicator = UIActivityIndicatorView()
    
    
    
    // MARK: - Standard Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)

        
        // Setting the online users reference
        onlineUsersReference = FIRDatabase.database().reference(withPath: "online users")
        
        
        // Change design of the UIActivityIndicatorView
        activityIndicator.activityIndicatorViewStyle = .whiteLarge // Make the indicator larger and color white (premade setting)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color? = .black                          // We wanted it larger, but not white, so setting color to .black
        activityIndicator.center = self.view.center                // Position where it has to rotate/be active
        self.view.addSubview(activityIndicator)                         // Put the UIActivityIndicatorView in the "self.view"
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    
    // MARK: - IBActions
    
    @IBAction func login(_ sender: UIButton) {
        
        // Start the activityIndicator
        self.activityIndicator.startAnimating()
        
        // Dismiss keyboard
        self.view.endEditing(true)
        
        // Check if all fields are filled out
        guard let emailAddress = emailAddressTextField.text,
            emailAddress != "",
            let password = passwordTextField.text,
            password != ""
            // If 1 of them isn't filled out
            else {
                
                // Create a UIAlertController
                let alertController = UIAlertController(title: "Login Error",
                                                        message: "Both fields must not be blank.",
                                                        preferredStyle: .alert
                )
                
                // Create a UIAlertAction
                let okAction = UIAlertAction(title: "OK",
                                             style: .cancel,
                                             handler: nil)
                
                // Add the alertAction to the alertController
                alertController.addAction(okAction)
                
                // Show/Present the controller
                present(alertController, animated: true, completion: nil)
                
                
                // Stop the activityIndicator
                self.activityIndicator.stopAnimating()
                
                // End the function
                return
        }
        
        // Try logging into firebase
        FIRAuth.auth()?.signIn(withEmail: emailAddress,
                               password: password,
                               completion: { (user, error) in
                                // If something went wrong
                                if let error = error {
                                    
                                    // Create a UIAlertController
                                    let alertController = UIAlertController(title: "Login Error",
                                                                            message: error.localizedDescription,
                                                                            preferredStyle: .alert
                                    )
                                    
                                    // Create a UIAlertAction
                                    let okAction = UIAlertAction(title: "OK",
                                                                 style: .cancel,
                                                                 handler: nil
                                    )
                                    
                                    // Add alertAction to alertController
                                    alertController.addAction(okAction)
                                    
                                    // Show/Present alertController
                                    self.present(alertController, animated: true, completion: nil)
                                    
                                    // Stop the activityIndicator
                                    self.activityIndicator.stopAnimating()
                                    
                                    // End the function
                                    return
                                }
                                
                                
                                // Verify email address
                                guard let currentUser = user, currentUser.isEmailVerified
                                    
                                    // If login couldn't be verified
                                    else {
                                        
                                        // Create a UIAlertController
                                        let alertController = UIAlertController(title: "Email address not confirmed",
                                                                                message: "You haven't confirmed your email address yet. We sent you a confirmation email upon registration. You can click the verification link in that email. If you lost that email we'll gladly send you a new confirmation email. In that case you ought to tap Resend confirmation email.",
                                                                                preferredStyle: .alert
                                        )
                                        
                                        // Create UIAlertActions
                                        let okAction = UIAlertAction(title: "Resend email",
                                                                     style: .default,
                                                                     handler: { (action) in
                                                                        user?.sendEmailVerification(completion: nil)
                                        })
                                        let cancelAction = UIAlertAction(title: "Cancel",
                                                                         style: .cancel,
                                                                         handler: nil
                                        )
                                        
                                        // Add the alertActions to the alertController
                                        alertController.addAction(okAction)
                                        alertController.addAction(cancelAction)
                                        
                                        // Show/Present the controller
                                        self.present(alertController, animated: true, completion: nil)
                                        
                                        // Stop the activityIndicator
                                        self.activityIndicator.stopAnimating()
                                        
                                        // End the function
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
                                // Create reference to "Users" in firebase
                                let existingUsersReference = FIRDatabase.database().reference(withPath: "Users")
                                
                                existingUsersReference.observe(.value, with: {snapshot in
                                    
                                    if !snapshot.hasChild(currentUser.uid) {
                                        
                                        let user: [String : Any] = ["userName": currentUser.displayName!, "emailAddress": currentUser.email!, "points": 20]
                                        let thisUserReference = existingUsersReference.child(currentUser.uid)
                                        thisUserReference.setValue(user)
                                    }
                                    self.activityIndicator.stopAnimating()
                                })
                                
                                sleep(1)

                                // Setting userID and userReference in the delegate
                                
                                let thisUserReference = existingUsersReference.child(currentUser.uid)
                                
                                thisUserReference.observe(.value, with: {snapshot in
                                    
                                        let user = User(with: snapshot)
                                        self.delegate?.setUser(user)

                                })
                                sleep(1)
                                
                                
                                self.rotateImages(degrees: 90)
                                self.perform(#selector(self.seperateImages), with: nil, afterDelay: 1)
                                
                                // Stop activityIndicator
                                self.activityIndicator.stopAnimating()
                                
                                // Go back to the ViewController you were on before you came to LogInViewController
                                self.perform(#selector(self.dismissing), with: nil, afterDelay: 2)
        })
        
        
    }
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Dismiss keyboard
        self.view.endEditing(true)
        
        // Go back to the ViewController you were on before you came to LogInViewController
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func stopKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(false)
    }
    
    // MARK: - Homemade Functions
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -150 // Move view 150 points upward
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
    
    // Function to empty textFields
    private func updateView(){
        emailAddressTextField.text = ""
        passwordTextField.text = ""
    }
    
    
    // MARK: - Opening Logo
    func rotateImages(degrees: Double){
        UIView.animate(withDuration: 1, animations: {
            self.imageSuperiorView.transform = CGAffineTransform(rotationAngle: CGFloat(degrees * (M_PI/180)))
        }
        )
    }
    
    func seperateImages(){
        UIView.animate(withDuration: 1, animations: {
            self.iconTopImageView.center.y -= self.view.frame.width / 2
            self.iconBottomImageView.center.y += self.view.frame.width / 2
            print("in animate")
        }
        )
        print("in seperator")
    }
    
    func dismissing(){
        self.dismiss(animated: true, completion: nil)
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

