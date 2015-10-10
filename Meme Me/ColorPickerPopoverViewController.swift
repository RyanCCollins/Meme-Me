//
//  ColorPickerPopoverViewController.swift
//  Meme Me
//
//  Created by Ryan Collins on 10/10/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

class ColorPickerPopoverViewController: UIViewController {
    @IBOutlet weak var colorPicker: UIColor!
    var fontAttributes: FontAttributes!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didChangeTextSize(sender: UIStepper) {
//        let fontSize = CGFloat(sender.value)
//        print(fontSize)
//        textSizeLabel.text = String(fontAttributes.fontSize)
//        let parent = self.presentingViewController as! MemeEditorViewController
//        parent.fontAttributes.fontSize = fontSize
//        parent.changeTextFieldFont()
    }

}