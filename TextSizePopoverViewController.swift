//
//  TextSizePopoverViewController.swift
//  Meme Me
//
//  Created by Ryan Collins on 10/10/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

class TextSizePopoverViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var fontPicker: UIPickerView!

    var fontAttributes: FontAttributes!
    var pickerData = [String]()
    let fontFamily = UIFont.familyNames()
    
    //#-MARK: Lifecycle Methods:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Fill array with font names:
        for family in fontFamily {
            pickerData.appendContentsOf((UIFont.fontNamesForFamilyName(family)))
        }
        
        //Set picker data source and delegate:
        fontPicker.dataSource = self
        fontPicker.delegate = self
        
        //Set default row selection of picker:
        setFontAttributeDefaults(fontAttributes.fontSize, fontName: fontAttributes.fontName, fontColor: fontAttributes.fontColor)
        setValuesOfUIElementsForFontAttributes()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Subscribe to shake notification:
        subscribeToShakeNotifications()
    }
    
    //Set view as first responder:
    override func viewDidAppear(animated: Bool) {
        becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubsribeToShakeNotification()
    }
    
    //#--MARK: Alert and reset the UI if user selects reset:
    func alertForReset() {
        let ac = UIAlertController(title: "Reset?", message: "Are you sure you want to reset the font size and type?", preferredStyle: .Alert)
        let resetAction = UIAlertAction(title: "Reset", style: .Default, handler: { Void in
            //Reset to default values and update the Meme's font:
            self.setFontAttributeDefaults(40.0, fontName: "HelveticaNeue-CondensedBlack", fontColor: UIColor.whiteColor())
            self.setValuesOfUIElementsForFontAttributes()
            self.updateMemeFont()
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        ac.addAction(resetAction)
        ac.addAction(cancelAction)
        presentViewController(ac, animated: true, completion: nil)
    }
    
    //Set default font attibutes:
    func setFontAttributeDefaults(fontSize: CGFloat = 40.0, fontName: String = "HelveticaNeue-CondensedBlack", fontColor: UIColor = UIColor.whiteColor()){
        fontAttributes.fontSize = fontSize
        fontAttributes.fontName = fontName
        fontAttributes.fontColor = fontColor
    }
    
    //#-MARK: Set UI Elements based on stored font attributes:
    func setValuesOfUIElementsForFontAttributes() {
        //Set font slider's value to the font size:
        fontSizeSlider.value = Float(fontAttributes.fontSize)
        
        //Set picker to font:
        let index = pickerData.indexOf(fontAttributes.fontName)
        if let index = index {
            fontPicker.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
    //update the MemeEditor font and reconfigure the view:
    func updateMemeFont(){
        let parent = presentingViewController as! MemeEditorViewController
        parent.fontAttributes.fontSize = fontAttributes.fontSize
        parent.fontAttributes.fontName = fontAttributes.fontName
        parent.configureTextFields([parent.topText, parent.bottomText])
    }
    
    //Respond to changes in the font slider:
    @IBAction func didChangeSlider(sender: UISlider) {
        //Cast value of font slider to CGFloat:
        let fontSize = CGFloat(fontSizeSlider.value)
        fontAttributes.fontSize = fontSize
        
        updateMemeFont()
    }
    
    //#-- MARK: Picker Delegate and Data Source methods:
    //# -- MARK: Data Sources:
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    //# -- MARK: Delegate Methods:
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        fontAttributes.fontName = pickerData[row]
        updateMemeFont()
    }
    
}