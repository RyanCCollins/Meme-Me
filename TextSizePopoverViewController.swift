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

        //Fill array with font names:
        for family in fontFamily {
            pickerData.appendContentsOf((UIFont.fontNamesForFamilyName(family)))
        }
        
        //Set initial slider value:
        fontSizeSlider.value = Float(fontAttributes.fontSize)
        
        //Set picker data source and delegate:
        fontPicker.dataSource = self
        fontPicker.delegate = self
        
        //Set default row selection of picker:
        let index = pickerData.indexOf(fontAttributes.fontName)
        if let index = index {
            fontPicker.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
    //Set as first responder:
    override func viewDidAppear(animated: Bool) {
        becomeFirstResponder()
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
    
    @IBAction func didChangeSlider(sender: UISlider) {
        //Cast value of font slider to CGFloat:
        let fontSize = CGFloat(fontSizeSlider.value)
        
        //Update meme editor text size value:
        let parent = presentingViewController as! MemeEditorViewController
        parent.fontAttributes.fontSize = fontSize
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
        let parent = presentingViewController as! MemeEditorViewController
        parent.fontAttributes.fontName = pickerData[row]
        parent.configureTextFields([parent.topText, parent.bottomText])
        fontAttributes.fontName = pickerData[row]
    }
    
}