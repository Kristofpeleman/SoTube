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
        "Black & White" : "background_black_white",
        "Purple" : "background_purple",
        "Yellow" : "background_yellow",
        "Orange" : "background_orange",
        "Blue" : "background_blue"
    ]
    
    var backGroundKeys: [String] {
        return backGroundColorData.map{$0.key}
    }
    
    var defaultValue: Int {
        return backGroundColorData.count - 1
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
    
}
