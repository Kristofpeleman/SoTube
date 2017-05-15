//
//  SortingOptions.swift
//  SoTube
//
//  Created by VDAB Cursist on 15/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import UIKit

class SortingOptions: NSObject, UIPickerViewDataSource {
    
    let values = ["Artist (A-Z)", "Artist (Z-A)", "Song Title (A-Z)", "Song Title (Z-A)"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values.count
    }
}
