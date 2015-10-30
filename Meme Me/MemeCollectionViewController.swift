//
//  MemeCollectionViewController.swift
//  Meme Me
//
//  Created by Ryan Collins on 10/2/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var memeCollectionView: UICollectionView!
    
    @IBOutlet weak var addOrDeleteButton: UIBarButtonItem!
    var selectedMemes = [Int]()
    var userEditing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setControllFlowLayout()
        
        memeCollectionView.allowsMultipleSelection = true
    }
    

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        collectionView!.reloadData()
        initUI()
    }

    func initUI () {
        navigationItem.leftBarButtonItem?.enabled = MemeCollection.allMemes.count > 0
        //If there are no saved memes, present the meme creator:
        if MemeCollection.allMemes.count == 0 {
            editButton.enabled = false
            setEditing(false, animated: true)
            launchEditor()
        }
    }

    func launchEditor () {
        let object: AnyObject = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController")
        let memeCreatorVC = object as! MemeEditorViewController
        presentViewController(memeCreatorVC, animated: false, completion: nil)
    }
    
    func setControllFlowLayout() {
        //Define control flow characteristics:
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        //Set up CollectionView Control flow properties:
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
    }
    
    @IBAction func didTapEdit(sender: UIBarButtonItem) {
        userEditing = !userEditing
        if userEditing {
            editButton.title = "Done"
            
            let deleteButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "deleteSelectedMemes")
            
            navigationItem.rightBarButtonItem = deleteButton
            
        } else {
            
        }
    }
    
    func deleteSelectedMemes(sender: AnyObject) {
        if selectedMemes.count > 0 {
            let sortedMemes = selectedMemes.sort{
                return $0 > $1
            }
            
            for index in sortedMemes {
                MemeCollection.remove(atIndex: index)
            }
            
            selectedMemes.removeAll()
            
            setEditing(false, animated: true)
        }
    }
    
    func alertBeforeDeleting(sender: AnyObject) {
        let ac = UIAlertController(title: "Delete Selected Memes", message: "Are you SURE that you want to delete the selected Memes?", preferredStyle: .Alert)
        let deleteAction = UIAlertAction(title: "Delete!", style: .Destructive, handler: {
                action in self.deleteSelectedMemes(sender)
        })
        
        let stopAction = UIAlertAction(title: "Keep Them", style: .Default, handler: {
            action in self.dismissViewControllerAnimated(true, completion: {
                self.initUI()
            })
        })
        
        ac.addAction(deleteAction)
        ac.addAction(stopAction)
        
        presentViewController(ac, animated: true, completion: nil)
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        collectionView?.reloadData()
    }
    
    @IBAction func didPressAdd(sender: AnyObject){
        let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController")
        let editMemeVC = object as! MemeEditorViewController
        presentViewController(editMemeVC, animated: true, completion: {
            editMemeVC.cancelButton.enabled = true
            editMemeVC.shareButton.enabled = true
        })
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //Return number of items in memes array:
        return MemeCollection.allMemes.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //Configure cell and return it:
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        
        let meme = MemeCollection.allMemes[indexPath.item]
        cell.topLabel?.text = meme.topText
        cell.bottomLabel?.text = meme.bottomText
        cell.memeImageView?.image = meme.originalImage
        
        if selectedMemes.contains(indexPath.item) {
            cell.isSelected(true)
        } else {
            cell.isSelected(false)
        }
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            //Instantiate the Meme Editor VC:
            if !editing {
                let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController")
                let detailVC = object as! MemeDetailViewController
                
                //Pass the data from the selected row to the detailVC:
                detailVC.meme = MemeCollection.allMemes[indexPath.item]
                //Present the view controller:
                navigationController!.pushViewController(detailVC, animated: true)
            } else {
                addOrDeleteButton.enabled = true
                let cell = collectionView.cellForItemAtIndexPath(indexPath)
                cell?.selected = true
                let index = indexPath.item
                selectedMemes.append(index)
        }
    }

}
