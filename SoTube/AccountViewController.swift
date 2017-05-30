//
//  AccountViewController.swift
//  SoTube
//
//  Created by Kristof Peleman on 26/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: TopMediaViewController, LoginViewControllerDelegate, MusicPlayerViewControllerDelegate, UIPickerViewDelegate {
    
    // MARK: - Global variables and constants
    
    var shared = Shared.current
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var loginButton: UIBarButtonItem!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailAddressLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var buyPointsButton: UIButton!
    
    @IBOutlet weak var goToMusicPlayerButton: UIBarButtonItem!
    
    @IBOutlet weak var backGroundPickerView: UIPickerView!
    
    @IBOutlet var backGroundPickerDataSource: BackGroundColors!
    
    
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
        
        self.songVCBackGroundImage.image = UIImage(named: Shared.current.backGroundImage)
        
        if shared.backGroundImage == backGroundPickerDataSource.defaultColorDescription {
        backGroundPickerView.selectRow(backGroundPickerDataSource.getRowForBackGroundColor("Neutral"), inComponent: 0, animated: false)
        } else {
            switch shared.backGroundImage {
            case "yellow_background":
                backGroundPickerView.selectRow(backGroundPickerDataSource.getRowForBackGroundColor("Yellow"), inComponent: 0, animated: false)
            case "purple_background":
                backGroundPickerView.selectRow(backGroundPickerDataSource.getRowForBackGroundColor("Purple"), inComponent: 0, animated: false)
            case "orange_background":
                backGroundPickerView.selectRow(backGroundPickerDataSource.getRowForBackGroundColor("Orange"), inComponent: 0, animated: false)
            case "red_background":
                backGroundPickerView.selectRow(backGroundPickerDataSource.getRowForBackGroundColor("Pink"), inComponent: 0, animated: false)
            case "green_background":
                backGroundPickerView.selectRow(backGroundPickerDataSource.getRowForBackGroundColor("Green"), inComponent: 0, animated: false)
            case "blue_background":
                backGroundPickerView.selectRow(backGroundPickerDataSource.getRowForBackGroundColor("Blue"), inComponent: 0, animated: false)
            default:
                backGroundPickerView.selectRow(backGroundPickerDataSource.getRowForBackGroundColor("Neutral"), inComponent: 0, animated: false)
            }
        }
        
        if let _ = shared.user {
            loginButton.title = "Log out"
            
            self.userNameLabel.text = shared.user?.userName
            self.emailAddressLabel.text = shared.user?.emailAddress
            self.pointsLabel.text = "\(shared.user!.points)"
            
            print(self.shared.user?.fireBaseID ?? "NO FIREBASE ID")
            print(self.shared.user?.userName ?? "NO USERNAME")
            print(self.shared.user?.emailAddress ?? "NO EMAIL")
            print(self.shared.user?.points ?? "NO POINTS")
            buyPointsButton.isEnabled = true
            
        } else {
            loginButton.title = "Log in"
            self.userNameLabel.text = "NO USER"
            self.emailAddressLabel.text = "NO USER"
            self.pointsLabel.text = "NO USER"
            buyPointsButton.isEnabled = false
            
            let alertController = UIAlertController(title: "No User found",
                                                    message: "You need to log in before you can see your account details",
                                                    preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: "OK",
                                         style: .cancel,
                                         handler: nil
            )
            
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
        }
        
        if shared.currentPositionInList != nil {
            goToMusicPlayerButton.isEnabled = true
        }
        else {
            goToMusicPlayerButton.isEnabled = false
        }
        
    }
    
    // MARK: - IBActions
    
    @IBAction func goToMusicPlayer(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "musicPlayerSegue", sender: sender)
    }
    
    @IBAction func buyPoints(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Buy Points",
                                                message: "Are you certain you want to buy 20 points?",
                                                preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "Yes",
                                     style: .default,
                                     handler: {
                                        (action) in
                                        self.shared.user!.points += 20
                                        self.updatePointsLabel()
                                        
                                        // Persist updated value to Firebase
                                        let currentPoints = self.shared.user?.points
                                        let usersReference = self.rootReference?.child("Users")
                                        let thisUserReference = usersReference?.child("\(self.shared.user?.fireBaseID ?? "dummy user")")
                                        let pointsReference = thisUserReference?.child("points")
                                        pointsReference?.setValue(currentPoints)
        }
        )
        
        let cancelAction = UIAlertAction(title: "No",
                                         style: .cancel,
                                         handler: nil
        )
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    
    // MARK: - Homemade Functions
    
    func updatePointsLabel(){
        if shared.user != nil {
        pointsLabel.text = String(describing: shared.user!.points)
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
        
        if segue.identifier == "musicPlayerSegue" {
            if let destinationVC = segue.destination as? MusicPlayerViewController {
                destinationVC.auth = self.auth
                destinationVC.session = self.session
                destinationVC.delegate = self
                
                if sender is UIBarButtonItem {
                    destinationVC.songList = self.shared.songList
                    destinationVC.currentSongPositionInList = self.shared.currentPositionInList
                }

                
                if let _ = self.shared.user {
                    
                    let usersReference: FIRDatabaseReference = rootReference!.child("Users")
                    let thisUserReference = usersReference.child(self.shared.user!.fireBaseID)
                    
                    destinationVC.userReference = thisUserReference
                }
                
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
            
        case "musicPlayerSegue":
            
            if sender is UIBarButtonItem {
                if let _ = self.shared.songList, let _ = self.shared.currentPositionInList {
                    return true
                }
                return false
                
            } else {return true}
        // If the identifier's value isn't any of the above: perform Segue
        default: return true
        }
    }
 
    // MARK: - UIPickerViewDelegate Methods
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return backGroundPickerDataSource.getBackGroundDescriptionFor(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
                    inComponent component: Int) {
        let imageName = backGroundPickerDataSource.getImageNameForSelected(row)
        self.songVCBackGroundImage.image = UIImage(named: imageName)
        shared.backGroundImage = imageName
    }
    
    
    // MARK: - LoginViewControllerDelegate methods
    
    func setUser(_ user: User) {
        self.shared.user = user
    }
    
    
    // MARK: - MusicPlayerViewControllerDelegate methods
    
    func setSongList(_ songList: [Song]) {
        self.shared.songList = songList
    }
    
    func setCurrentPositionInList(_ position: Int) {
        self.shared.currentPositionInList = position
    }
    

}
