//
//  Meme.swift
//  Meme Me
//
//  Created by Ryan Collins on 9/29/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

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
    
    static func updateMeme(atIndex index: Int, withMeme meme: Meme) {
        getMemeStorage().memes[index] = meme
    }
    
    static func remove(atIndex index: Int) {
        getMemeStorage().memes.removeAtIndex(index)
    }
    
    //Locate the meme storage location
    static func getMemeStorage() -> AppDelegate {
        let object = UIApplication.sharedApplication().delegate
        return object as! AppDelegate
    }
}

////    init(topText: String, bottomText: String, originalImage: UIImage, memedImage: UIImage, fontAttributes: FontAttributes) {
////        self.topText = topText
////        self.bottomText = bottomText
////        self.originalImage = originalImage
////        self.memedImage = memedImage
////        
////        //Define font attributes:
////        self.fontAttributes = fontAttributes
////    }
//    
//    //Function to save the meme:
//    func saveMeme() {
//        Meme.getMemeStorage().memes.append(self)
//    }
//    
//    //Function to update an existing meme:
//    mutating func updateMeme(atIndex index: Int, topText: String, bottomText: String, originalImage:UIImage, memedImage: UIImage, fontAttributes: FontAttributes) {
//        var editMeme
//        self.topText = topText
//        self.bottomText = bottomText
//        self.originalImage = originalImage
//        self.memedImage = memedImage
//        
//        self.fontAttributes = fontAttributes
//    }
//    
//    //Update font traits:
//    mutating func changeMemeFont(atIndex index: Int) {
//        let meme = getMemeAtIndex(index)
//        meme.fontColor = fontColor
//        fontAttributes.fontSize = fontSize
//    }
//    
//    //Collect all memes into an array:
//    static func getAll() -> [Meme] {
//        return Meme.getMemeStorage().memes
//    }
//    
//    //Return the location of our appdelegate meme object:
//    static func getMemeStorage() -> AppDelegate {
//        let object = UIApplication.sharedApplication().delegate
//        return object as! AppDelegate
//    }
//    
//    static func countMemes() -> Int {
//        return getAll().count
//    }
//    
//    static func getMemeAtIndex(index: Int) -> Meme? {
//        if Meme.getMemeStorage().memes.count > index {
//            return Meme.getMemeStorage().memes[index]
//        }
//        return nil
//    }
//    
//    static func removeMemeAtIndex(index: Int) {
//        if index >= 0 {
//            Meme.getMemeStorage().memes.removeAtIndex(index)
//        }
//    }
//}

struct FontAttributes {
    var fontSize: CGFloat = 40.0
    var fontName = "HelveticaNeue-CondensedBlack"
    var fontColor = UIColor.whiteColor()
    var borderColor = UIColor.blackColor()

//    init(fontSize: CGFloat = 40.0, fontName: String = "HelveticaNeue-CondensedBlack", fontColor: UIColor = UIColor.whiteColor(), borderColor: UIColor = UIColor.blackColor()) {
//        self.fontSize = fontSize
//        self.fontName = fontName
//        self.fontColor = fontColor
//        self.borderColor = borderColor
//    }
}
