//
//  MemeTableViewController.swift
//  Meme Me
//
//  Created by Ryan Collins on 10/2/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

class MemeTableViewController: UITableViewController {
    var selectedIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Add edit button
        navigationItem.leftBarButtonItem = editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //If there are no saved memes, present the meme creator:
        if Meme.countMemes() == 0 {
            let object: AnyObject = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController")
            let memeCreatorVC = object as! MemeEditorViewController
            presentViewController(memeCreatorVC, animated: false, completion: nil)
        }
        navigationItem.leftBarButtonItem?.enabled = Meme.countMemes() > 0
        tableView!.reloadData()
    }
    
    
    //Present the meme editor empty:
    @IBAction func didPressAdd(sender: AnyObject) {
        //Segue to the new meme view programmatically:
        let object: AnyObject = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController")
        let newMemeVC = object as! MemeEditorViewController
        presentViewController(newMemeVC, animated: true, completion: {
            newMemeVC.cancelButton.enabled = true
        })
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table View Data source & Delegate methods:

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Return the number of objects in the meme array:
        return Meme.countMemes()
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeTableCell", forIndexPath: indexPath)
        
        //Configure Tableview Cell
        if let meme = Meme.getMemeAtIndex(indexPath.row) {
            cell.textLabel!.text = "\(meme.topText) \(meme.bottomText)"
            cell.imageView!.image = meme.originalImage
        }
        return cell
    }
    
    //MARK: - allow tableView editing:
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //Delete selected Meme:
        switch editingStyle {
        case .Delete:
            Meme.removeMemeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
        default:
            return
        }
        
    }
    
    //Show detail View from selection.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //If not editing, perform segue defined in storyboard:
        if !tableView.editing {
            selectedIndex = indexPath.row
            print(selectedIndex)
            self.performSegueWithIdentifier("showDetail", sender: self)
        }
    }
    

    
    //Methods for editing the tableView:
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        //Switch bar button item between Edit and Done:
        if !tableView.editing {
            tableView.setEditing(editing, animated: animated)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let destinationVC = segue.destinationViewController as! MemeDetailViewController
            if let meme = Meme.getMemeAtIndex(selectedIndex) {
                destinationVC.meme = meme
            }
        }
    }
}
