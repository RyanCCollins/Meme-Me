//
//  Meme.swift
//  Meme Me
//
//  Created by Ryan Collins on 9/29/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import Foundation

//Main Struct for Meme Data Model:
struct Meme {
    var topText: String!
    var bottomText: String!
    var originalImage: UIImage!
    var memedImage: UIImage!
    var fontAttributes: FontAttributes!
    
}

//Add the Equatable Protocol and make equal if the memedImages match:
extension Meme: Equatable {}

func ==(lhs: Meme, rhs: Meme) -> Bool {
    return lhs.memedImage == rhs.memedImage
}

//Handy methods and variables for accessing and altering the collection of Memes:
struct MemeCollection {

    //Get all memes from our app delegate:
    static var allMemes: [Meme] {
        return getMemeStorage().memes
    }
    
    //Return a Meme at a given index:
    static func getMeme(atIndex index: Int) -> Meme {
        return allMemes[index]
    }
    
    //Find the index of a given Meme:
    static func indexOf(meme: Meme) -> Int {
        //If the meme is in the collection, return first index, otherwise return count.
        if let index = allMemes.indexOf({$0 == meme}) {
            return Int(index)
        } else {
            print(allMemes.count)
            return allMemes.count
        }
    }
    
    //Add a meme to the last position of the meme collection:
    static func add(meme: Meme) {
        getMemeStorage().memes.append(meme)
    }
    
    //Update a given Meme with a new Meme at a given index:
    static func update(atIndex index: Int, withMeme meme: Meme) {
        getMemeStorage().memes[index] = meme
    }
    
    //Remove a Meme at a given index:
    static func remove(atIndex index: Int) {
        getMemeStorage().memes.removeAtIndex(index)
    }
    
    //Get a count of all Memes in our Meme Collection:
    static func count() -> Int {
        return getMemeStorage().memes.count
    }
    
    //Locate the meme storage location in our App Delegate:
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
