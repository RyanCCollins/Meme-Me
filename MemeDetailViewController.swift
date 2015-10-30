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
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMemeEditor" {
            let editVC = segue.destinationViewController as! MemeEditorViewController
            editVC.editMeme = meme
            editVC.editMemeIndex = memeIndex
            editVC.userIsEditing = true
        }
    }

}
