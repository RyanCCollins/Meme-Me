//
//  Meme.swift
//  Meme Me
//
//  Created by Ryan Collins on 9/29/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import Foundation

struct Meme {
    var topText: String!
    var bottomText: String!
    var originalImage: UIImage!
    var memedImage: UIImage!
    var fontAttributes: FontAttributes!
}

extension Meme {
    static var allMemes: [Meme] {
        return getMemeStorage().memes
    }
    
    static func add(meme: Meme) {
        getMemeStorage().memes.append(meme)
    }
    
    static func update(meme: Meme, withMeme: Meme) {
        getMemeStorage().memes.
    }
    
    static func remove(atIndex index: Int) {
        getMemeStorage().memes.removeAtIndex(index)
    }
    
    static func count() -> Int {
        return getMemeStorage().memes.count
    }
    
    //Locate the meme storage location
    static func getMemeStorage() -> AppDelegate {
        let object = UIApplication.sharedApplication().delegate
        return object as! AppDelegate
    }
}

struct MemeCollection {
    var allMemes: [Memes] {
        return ge
    }
}

//Stores font attributes for a meme:
struct FontAttributes {
    var fontSize: CGFloat = 40.0
    var fontName = "HelveticaNeue-CondensedBlack"
    var fontColor = UIColor.whiteColor()
    var borderColor = UIColor.blackColor()
}
