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

struct MemeCollection {

    static var allMemes: [Meme] {
        return getMemeStorage().memes
    }
    
    static func getMeme(atIndex index: Int) -> Meme {
        return allMemes[index]
    }
    
    static func indexOf(meme: Meme) -> Int {
        if let index = allMemes.indexOf({$0.memedImage == meme.memedImage}) {
            return Int(index)
        } else {
            print(allMemes.count)
            return allMemes.count
        }
    }
    
    static func add(meme: Meme) {
        getMemeStorage().memes.append(meme)
    }
    
    static func update(atIndex index: Int, withMeme meme: Meme) {
        getMemeStorage().memes[index] = meme
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


//Stores font attributes for a meme:
struct FontAttributes {
    var fontSize: CGFloat = 40.0
    var fontName = "HelveticaNeue-CondensedBlack"
    var fontColor = UIColor.whiteColor()
    var borderColor = UIColor.blackColor()
}
