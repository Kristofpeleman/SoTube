//
//  BackgroundColors.swift
//  SoTube
//
//  Created by Kristof Peleman on 27/05/17.
//  Copyright © 2017 VDAB Cursist. All rights reserved.
//

import Foundation

class BackGroundColors: NSObject, UIPickerViewDataSource {
    

    let backGroundColorData: [String : String] = [
        "Neutral" : "black_white_background",
        "Purple" : "purple_background",
        "Yellow" : "yellow_background",
        "Orange" : "orange_background",
        "Blue" : "blue_background",
        "Pink" : "red_background",
        "Green" : "green_background"
    ]
    
    let backGroundColorOrder: [String: Int] = [
        "Yellow" : 0,
        "Purple" : 1,
        "Orange" : 2,
        "Pink" : 3,
        "Neutral" : 4,
        "Green" : 5,
        "Blue" : 6
    ]
    
    let defaultColorDescription: String = "black_white_background"
    
    var backGroundKeys: [String] {
        return backGroundColorData.map{$0.key}
    }
    
    var defaultValue: Int {
        return backGroundColorData.count - 3
    }
    
    func numberOfComponents(in: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return backGroundColorData.count
    }
    
    func getBackGroundDescriptionFor(_ row: Int) -> String {
        return backGroundKeys[row]
    }
    
    func getImageNameForSelected(_ row: Int) -> String {
        let key = self.backGroundKeys[row]
        return self.backGroundColorData[key]!
    }
    
    func getRowForBackGroundColor(_ color: String) -> Int {
        return backGroundColorOrder[color]!
    }
    
}
