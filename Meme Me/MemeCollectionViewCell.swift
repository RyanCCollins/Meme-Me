//
//  MemeCollectionViewCell.swift
//  Meme Me
//
//  Created by Ryan Collins on 10/2/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

/* Define outlets and methods for collection view cell */
class MemeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var selectedImageView: UIImageView!
    
    /* Show or hide the checkmark if cell is selected */
    func isSelected(selected: Bool) {
        if selected {
            selectedImageView.hidden = false
        } else {
            selectedImageView.hidden = true
        }
    }
}
