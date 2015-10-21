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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Subscribe to shake notification:
        subscribeToShakeNotifications()
        
        //Fill array with font names:
        for family in fontFamily {
            pickerData.appendContentsOf((UIFont.fontNamesForFamilyName(family)))
        }
        
        //Set picker data source and delegate:
        fontPicker.dataSource = self
        fontPicker.delegate = self
        
        //Set default row selection of picker:
        setDefaultValues(Float(fontAttributes.fontSize), fontName: fontAttributes.fontName)
    }
    
    func setDefaultValues(fontSize: Float, fontName: String){
        fontSizeSlider.value = fontSize
        fontAttributes.fontSize = CGFloat(fontSize)
        
        fontAttributes.fontName = fontName
        let index = pickerData.indexOf(fontAttributes.fontName)
        if let index = index {
            fontPicker.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
    //Set as first responder:
    override func viewDidAppear(animated: Bool) {
        becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubsribeToShakeNotification()
    }
    
    //#--MARK: Subsribe to shake notifications:
    func subscribeToShakeNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "alertForReset", name: "shake", object: nil)
    }
    
    func unsubsribeToShakeNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "shake", object: nil)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    //Handle motion events:
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == UIEventSubtype.MotionShake {
            NSNotificationCenter.defaultCenter().postNotificationName("shake", object: self)
            print("shake!")
        
        }
    }
    
    func alertForReset() {
        let ac = UIAlertController(title: "Reset?", message: "Are you sure you want to reset the font size and type?", preferredStyle: .Alert)
        let resetAction = UIAlertAction(title: "Reset", style: .Default, handler: { Void in
            //Reset to default values and update the Meme's font:
            self.setDefaultValues(40.0, fontName: "HelveticaNeue-CondensedBlack")
            self.updateMemeFont()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        ac.addAction(resetAction)
        ac.addAction(cancelAction)
        presentViewController(ac, animated: true, completion: nil)
    }

    
    @IBAction func didChangeSlider(sender: UISlider) {
        //Cast value of font slider to CGFloat:
        let fontSize = CGFloat(fontSizeSlider.value)
        fontAttributes.fontSize = fontSize
        
        updateMemeFont()
    }
    
    func updateMemeFont(){
        //update the MemeEditor font and reconfigure the view:
        let parent = presentingViewController as! MemeEditorViewController
        parent.fontAttributes.fontSize = fontAttributes.fontSize
        parent.fontAttributes.fontName = fontAttributes.fontName
        parent.configureTextFields([parent.topText, parent.bottomText])
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