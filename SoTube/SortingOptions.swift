//
//  SortingOptions.swift
//  SoTube
//
//  Created by VDAB Cursist on 15/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit

// Dragged an Object into storyBoard that uses this .swift file; Also has to follow UIPickerViewDataSource-protocol
class SortingOptions: NSObject, UIPickerViewDataSource {
    
    // The values inside our pickerView (text per row)
    let values = ["None", "Artist (A-Z)", "Artist (Z-A)", "Song Title (A-Z)", "Song Title (Z-A)"]
    
    // Amount of scrollers in pickerView (0 = nothing)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Amount of rows inside the pickerView's component
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values.count
    }
}
