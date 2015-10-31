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
    @IBOutlet weak var memeCollectionView: UICollectionView!
    
    var selectedMemes = [NSIndexPath]()
    var editingMode = false
    var editButton: UIBarButtonItem!
    var addDeleteButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setControllFlowLayout()
        
        memeCollectionView.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        initUI()
    }

    func initUI () {
        //Initialize and add the edit/add buttons:
        editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "didTapEdit:")
        addDeleteButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "launchEditor:")
        navigationItem.rightBarButtonItem = addDeleteButton
        navigationItem.leftBarButtonItem = editButton
        navigationItem.leftBarButtonItem?.enabled = MemeCollection.allMemes.count > 0
        
        //Cycle through each cell and index in selectMemes array to deselect and reinitialize:
        for index in selectedMemes {
//            memeCollectionView.deselectItemAtIndexPath(index, animated: true)
            let cell = memeCollectionView.cellForItemAtIndexPath(index) as! MemeCollectionViewCell
            cell.isSelected(false)
        }
        
        //Remove all items from the selected Memes array:
        selectedMemes.removeAll()
        memeCollectionView.reloadData()
        
        //If there are no saved memes, present the meme creator:
        if MemeCollection.allMemes.count == 0 {
            editButton.enabled = false
            launchEditor(self)
        } else {
            editButton.enabled = true
        }
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
    
    func didTapEdit(sender: UIBarButtonItem?) {
        editingMode = !editingMode

        if editingMode {
            editButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "didTapEdit:")
            navigationItem.leftBarButtonItem = editButton
            //Set right bar button item and disable it until an item is selected:
            addDeleteButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "alertBeforeDeleting:")
            navigationItem.rightBarButtonItem = addDeleteButton
            navigationItem.rightBarButtonItem?.enabled = false
        } else {
            //If no longer editing, remove items from set and refresh view
            initUI()
        }
    }
    
    
    func launchEditor(sender: AnyObject){
        let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController")
        let editMemeVC = object as! MemeEditorViewController
        presentViewController(editMemeVC, animated: true, completion: {
            editMemeVC.cancelButton.enabled = true
            editMemeVC.shareButton.enabled = true
        })
    }
    
}

//#-MARK: Delete Memes:
extension MemeCollectionViewController {
    func deleteSelectedMemes(sender: AnyObject) {
        if selectedMemes.count > 0 {
            let sortedMemes = selectedMemes.sort{
                return $0.item > $1.item
            }
            
            for index in sortedMemes {
                MemeCollection.remove(atIndex: index.item)
            }
            
            selectedMemes.removeAll()
    
            initUI()
        }
    }
    
    //Alert the user before deletion:
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
}

//#-MARK: Collection View Delegate and Data Source Methods
extension MemeCollectionViewController {

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
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //If editing, select and add to the array of indexes
        if editingMode {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MemeCollectionViewCell
            
            let index = indexPath
            selectedMemes.append(index)
            cell.isSelected(true)
            addDeleteButton.enabled = true
        } else {
            //If not editing, show Meme detail:
            let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController")
            let detailVC = object as! MemeDetailViewController
            
            //Pass the data from the selected row to the detailVC:
            detailVC.meme = MemeCollection.allMemes[indexPath.item]
            //Present the view controller:
            navigationController!.pushViewController(detailVC, animated: true)
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if editingMode {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MemeCollectionViewCell
            selectedMemes.removeAtIndex(indexPath.item)
            cell.isSelected(false)
        }
        navigationItem.rightBarButtonItem?.enabled = (selectedMemes.count > 0)
    }
}