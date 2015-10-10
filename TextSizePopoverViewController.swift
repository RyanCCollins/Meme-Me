//
//  TextSizePopoverViewController.swift
//  Meme Me
//
//  Created by Ryan Collins on 10/10/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import Foundation
import UIKit

class TextSizePopoverViewController: UIViewController {
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var textSizeLabel: UILabel!
    var textSize: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set textSizeLabel:
        textSizeLabel.text? = String(textSize)
    }
    
    @IBAction func didChangeTextSize(sender: AnyObject) {
        textSize = Int(stepper.value)
        textSizeLabel.text = String(textSize)
        let parent = self.parentViewController as! MemeEditorViewController
        parent.textSize = textSize
        parent.
    }
    
}