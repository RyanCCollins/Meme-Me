//
//  MemeCollectionViewCell.swift
//  Meme Me
//
//  Created by Ryan Collins on 10/2/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

class MemeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var selectedImageView: UIImageView!
    

    func isSelected(selected: Bool) {
        if selected {
            selectedImageView.hidden = false
        } else {
            selectedImageView.hidden = true
        }
    }
}
