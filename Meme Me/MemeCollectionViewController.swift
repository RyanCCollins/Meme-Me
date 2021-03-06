//
//  MemeCollectionViewController.swift
//  Meme Me
//
//  Created by Ryan Collins on 10/2/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var memeCollectionView: UICollectionView!
    let minimumSpacing: CGFloat = 5.0
    let sectionInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    
    var selectedMemes = [NSIndexPath]()
    var editingMode = false
    var editButton: UIBarButtonItem!
    var addDeleteButton: UIBarButtonItem!
    
    //# -- MARK: Lifecycle Methods
    
    /*  Allow multi selection of cells */
    override func viewDidLoad() {
        super.viewDidLoad()
        memeCollectionView.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        setDefaultUIState()
    }
    
    /*  Set the default user interface state */
    func setDefaultUIState () {
        /*  Initialize and add the edit/add buttons */
        editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "didTapEdit:")
        addDeleteButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "launchEditor:")
        
        navigationItem.rightBarButtonItem = addDeleteButton
        navigationItem.leftBarButtonItem = editButton
        navigationItem.leftBarButtonItem?.enabled = MemeCollection.allMemes.count > 0
        
        /* Cycle through each cell and index in selectMemes array to deselect and reinitialize */
        for index in selectedMemes {
            memeCollectionView.deselectItemAtIndexPath(index, animated: true)
            let cell = memeCollectionView.cellForItemAtIndexPath(index) as! MemeCollectionViewCell
            cell.isSelected(false)
        }
        
        /* Remove all items from the selected Memes array and reset layout */
        selectedMemes.removeAll()
        memeCollectionView.reloadData()
        
        editingMode = false
        
        /* If there are no saved memes, present the meme creator */
        if MemeCollection.allMemes.count == 0 {
            editButton.enabled = false
            launchEditor(self)
        } else {
            editButton.enabled = true
        }
    }
    
     /* Handle editing for the collection view multi selection */
    func didTapEdit(sender: UIBarButtonItem?) {
        editingMode = !editingMode
        
         /* If editing, change edit button to done and add button to trash */
        if editingMode {
           
            editButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "didTapEdit:")
            navigationItem.leftBarButtonItem = editButton
            
            /* Set right bar button item and disable it until an item is selected */
            addDeleteButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "alertBeforeDeleting:")
            navigationItem.rightBarButtonItem = addDeleteButton
            navigationItem.rightBarButtonItem?.enabled = false
        } else {
            /* If no longer editing, reitialize UI to base layout */
            setDefaultUIState()
        }
    }
    
    /* Launch the Meme editor with cancel/share button enabled */
    func launchEditor(sender: AnyObject){
        let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController")
        let editMemeVC = object as! MemeEditorViewController
        
        presentViewController(editMemeVC, animated: true, completion: {
            editMemeVC.cancelButton.enabled = true
            editMemeVC.shareButton.enabled = true
        })
    }
}

//# -- MARK: Delete Memes extension:
extension MemeCollectionViewController {
    
    /* Delete selected Memes when prompted */
    func deleteSelectedMemes(sender: AnyObject) {
        if selectedMemes.count > 0 {
            
            /* Sort the array of  selected Memes for deletion */
            let sortedMemes = selectedMemes.sort {
                return $0.item > $1.item
            }
            
            /* Remove the memes by cycling through sorted array and then reconfigure the UI */
            for index in sortedMemes {
                MemeCollection.remove(atIndex: index.item)
            }
            setDefaultUIState()
        }
    }
    
    /* Alert the user before deletion, giving the opportunity to cancel */
    func alertBeforeDeleting(sender: AnyObject) {
        let ac = UIAlertController(title: "Delete Selected Memes", message: "Are you SURE that you want to delete the selected Memes?", preferredStyle: .Alert)
        
        /* Configure the alert actions */
        let deleteAction = UIAlertAction(title: "Delete!", style: .Destructive, handler: {
            action in self.deleteSelectedMemes(sender)
        })
        
        let stopAction = UIAlertAction(title: "Keep Them", style: .Default, handler: {
            action in self.setDefaultUIState()
        })
        
        /* Add actions then present alert */
        ac.addAction(deleteAction)
        ac.addAction(stopAction)
        presentViewController(ac, animated: true, completion: nil)
    }
}

//# -- MARK: Collection View Delegate and Data Source Methods
extension MemeCollectionViewController {
    
    /* Return number of items in memes array */
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MemeCollection.allMemes.count
    }
    
    /* Configure collection view cells for each Meme */
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        
        let meme = MemeCollection.allMemes[indexPath.item]
        cell.memeImageView?.image = meme.memedImage
        
        return cell
    }
    
    /* Define behavior when a cell is selected */
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        /* If editing, select and add to the array of indexes */
        if editingMode {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MemeCollectionViewCell
            
            selectedMemes.append(indexPath)
            cell.isSelected(true)
            addDeleteButton.enabled = true
            
        } else {
            
            /* If not editing, pass the data from the selected row to the detail view and present */
            let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController")
            let detailVC = object as! MemeDetailViewController
            
            detailVC.meme = MemeCollection.allMemes[indexPath.item]
            navigationController!.pushViewController(detailVC, animated: true)
            
        }
    }
    
    /* Define behavior when a cell is deselected */
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        /* Enable delete button if cell is selected, disable if not */
        navigationItem.rightBarButtonItem?.enabled = (selectedMemes.count > 0)
        
        /* If editing, deselect and remove from array of selected memes */
        if editingMode {
            
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MemeCollectionViewCell
            selectedMemes.removeAtIndex(indexPath.item)
            cell.isSelected(false)
            
        }
    }
    
}
