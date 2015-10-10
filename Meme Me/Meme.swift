//
//  Meme.swift
//  Meme Me
//
//  Created by Ryan Collins on 9/29/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

class Meme: NSObject {
    var topText: String!
    var bottomText: String!
    var originalImage: UIImage!
    var memedImage: UIImage!
    var fontAttributes: FontAttributes!
    
//    var fontSize: CGFloat!
//    var fontColor: UIColor!
//    var borderColor: UIColor!
    
    init(topText: String, bottomText: String, originalImage: UIImage, memedImage: UIImage, fontAttributes: FontAttributes) {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
        
        //Define font attributes:
        self.fontAttributes = fontAttributes
    }
    
    //Function to save the meme:
    func saveMeme() {
        Meme.getMemeStorage().memes.append(self)
    }
    
    //Function to update an existing meme:
    func updateMeme(topText: String, bottomText: String, originalImage:UIImage, memedImage: UIImage, fontAttributes: FontAttributes) {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
        
        self.fontAttributes = fontAttributes
    }
    
    //Update font traits:
    func changeFont(fontSize: CGFloat, fontColor: UIColor) {
        fontAttributes.fontColor = fontColor
        fontAttributes.fontSize = fontSize
    }
    
    //Collect all memes into an array:
    class func getAll() -> [Meme] {
        return Meme.getMemeStorage().memes
    }
    
    //Return the location of our appdelegate meme object:
    class func getMemeStorage() -> AppDelegate {
        let object = UIApplication.sharedApplication().delegate
        return object as! AppDelegate
    }
    
    class func countMemes() -> Int {
        return Meme.getMemeStorage().memes.count
    }
    
    class func getMemeAtIndex(index: Int) -> Meme? {
        if Meme.getMemeStorage().memes.count > index {
            return Meme.getMemeStorage().memes[index]
        }
        return nil
    }
    
    class func removeMemeAtIndex(index: Int) {
        if index >= 0 {
            Meme.getMemeStorage().memes.removeAtIndex(index)
        }
    }
}

struct FontAttributes {
    var fontSize: CGFloat!
    var fontName: String!
    var fontColor: UIColor
    var borderColor: UIColor!

    init(fontSize: CGFloat = 40.0, fontName: String = "HelveticaNeue-CondensedBlack", fontColor: UIColor = UIColor.whiteColor(), borderColor: UIColor = UIColor.blackColor()) {
        self.fontSize = fontSize
        self.fontName = fontName
        self.fontColor = fontColor
        self.borderColor = borderColor
    }
}
