//
//  TextSizePopoverViewController.swift
//  Meme Me
//
//  Created by Ryan Collins on 10/10/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

class TextSizePopoverViewController: UIViewController {
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var textSizeLabel: UILabel!
    var fontAttributes: FontAttributes!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set textSizeLabel:
        textSizeLabel.text = String(fontAttributes.fontSize)
    }
    
    @IBAction func didChangeTextSize(sender: UIStepper) {
        let fontSize = CGFloat(sender.value)
        fontAttributes.fontSize = fontSize
        textSizeLabel.text = String(fontAttributes.fontSize)
        let parent = self.presentingViewController as! MemeEditorViewController
        parent.fontAttributes.fontSize = fontSize
        parent.changeTextFieldFont()
    }
    
}