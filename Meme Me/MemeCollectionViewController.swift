//
//  MemeCollectionViewController.swift
//  Meme Me
//
//  Created by Ryan Collins on 10/2/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UICollectionViewController {

    var memes = (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Define control flow characteristics:
        let space: CGFloat = 3.0
        let dimension = (self.view.frame.size.width - (2 * space)) / 3.0
        
        //Set up CollectionView Control flow properties:
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        collectionView!.reloadData()
        
        navigationItem.leftBarButtonItem?.enabled = Meme.countMemes() > 0
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        collectionView?.reloadData()
    }
    
    @IBAction func didPressAdd(sender: AnyObject){
        let object: AnyObject = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController")
        let editMemeVC = object as! MemeEditorViewController
        self.presentViewController(editMemeVC, animated: true, completion: {
            editMemeVC.cancelButton.enabled = true
            editMemeVC.shareButton.enabled = true
        })
    }
    
    @IBAction func didPressDelete(sender: UIButton) {
        let cell = sender.superview!.superview! as! MemeCollectionViewCell
        let indexPath = collectionView!.indexPathForCell(cell)!
        Meme.removeMemeAtIndex(indexPath.row)
        collectionView!.deleteItemsAtIndexPaths([indexPath])
        navigationItem.leftBarButtonItem?.enabled = Meme.countMemes() > 0
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //Return number of items in memes array:
        return Meme.countMemes()
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //Configure cell and return it:
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        
        if let meme = Meme.getMemeAtIndex(indexPath.row) {
            cell.topLabel?.text = meme.topText
            cell.bottomLabel?.text = meme.bottomText
            cell.memeImageView?.image = meme.originalImage
        }
        cell.deleteButton.hidden = !editing
        cell.deleteButton.addTarget(self, action: "didPressDelete:", forControlEvents: .TouchUpInside)
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            //Instantiate the Meme Editor VC:
            if !editing {
                let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController")
                let detailVC = object as! MemeDetailViewController
                
                //Pass the data from the selected row to the detailVC:
                detailVC.meme = Meme.getMemeAtIndex(indexPath.row)
                
                //Present the view controller:
                navigationController!.pushViewController(detailVC, animated: true)
        }
    }

}
