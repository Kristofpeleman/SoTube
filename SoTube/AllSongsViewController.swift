//
//  AllSongsViewController.swift
//  SoTube
//
//  Created by VDAB Cursist on 09/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit

class AllSongsViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get contents of MediaView.xib
        let nibConcentents = Bundle.main.loadNibNamed("MediaView", owner: nil, options: nil)
        // put nibContents into plainView as a MediaView (UIView)
        let plainView = nibConcentents?.last as! MediaView
        // the size and positioning of plainview has to be the same as self.view
        plainView.frame = self.view.frame
        // adding plainview to the visuals of self.view
        self.view.addSubview(plainView)
        
        plainView.titelLabel.text = "All Songs"
        
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
