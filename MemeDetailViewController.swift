//
//  MemeDetailViewController.swift
//  Meme Me
//
//  Created by Ryan Collins on 10/2/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    var memeIndex: Int?
    var meme: Meme?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let index = memeIndex {
            meme = Meme.allMemes[index]
            imageView.image = meme!.memedImage
        } else {
            memeIndex = -1
            alertUserOfError("Error", message: "Meme failed to load.  Please try again.")
        }
    }
    
    //Alert user if something has failed to load
    func alertUserOfError(title: String, message: String, style: UIAlertControllerStyle = .Alert) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: style)
        presentViewController(ac, animated: true, completion: {
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMemeEditor" {
            let editVC = segue.destinationViewController as! MemeEditorViewController
            editVC.editMeme = meme
            editVC.userIsEditing = true
        }
    }

}
