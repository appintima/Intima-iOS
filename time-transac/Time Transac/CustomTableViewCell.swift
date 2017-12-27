//
//  CustomTableViewCell.swift
//  Time Transac
//
//  Created by Gbenga Ayobami on 2017-07-13.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import UIKit

protocol CustomTableViewCellDelegate {
    func textFieldClicked(sender: CustomTableViewCell, textfield: UITextField)
}

class CustomTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var delegate: CustomTableViewCellDelegate?
    
    @IBOutlet weak var skillNameLabel: UILabel!
    @IBOutlet weak var xpLevelTF: UITextField!
    var xp = ["Beginner", "Intermediate", "Expert"]
    
    let picker = UIPickerView()
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        picker.delegate = self
        picker.dataSource = self
        
        xpLevelTF.inputView = picker
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return xp.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return xp[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.xpLevelTF.text = xp[row]
        self.endEditing(false)
    }

}
