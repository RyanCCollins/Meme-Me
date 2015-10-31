//
//  MemeTableViewController.swift
//  Meme Me
//
//  Created by Ryan Collins on 10/2/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

class MemeTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Add edit button
        navigationItem.leftBarButtonItem = editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //If there are no saved memes, present the meme creator:
        if MemeCollection.count() == 0 {
            let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController")
            let memeCreatorVC = object as! MemeEditorViewController
            presentViewController(memeCreatorVC, animated: false, completion: nil)
        }
        navigationItem.leftBarButtonItem?.enabled = MemeCollection.count() > 0
        tableView!.reloadData()
    }
    
    
    //Present the meme editor empty:
    @IBAction func didPressAdd(sender: AnyObject) {
        //Segue to the new meme view programmatically:
        let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController")
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
        return MemeCollection.count()
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeTableCell", forIndexPath: indexPath)
        
        //Configure Tableview Cell
        let meme = MemeCollection.allMemes[indexPath.row]
        cell.textLabel!.text = "\(meme.topText) \(meme.bottomText)"
        cell.imageView!.image = meme.originalImage

        return cell
    }
    
    //MARK: - allow tableView editing:
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //Delete selected Meme:
        switch editingStyle {
        case .Delete:
            MemeCollection.remove(atIndex: indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            //If there are no saved memes, present the meme creator:
            if MemeCollection.count() == 0 {
                let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController")
                let memeCreatorVC = object as! MemeEditorViewController
                presentViewController(memeCreatorVC, animated: false, completion: nil)
            }
        default:
            return
        }
        
    }
    
    //Show detail View from selection.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //If not editing, perform segue defined in storyboard:
        if !tableView.editing {
            let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController")
            let detailVC = object as! MemeDetailViewController
            
            //Pass the data from the selected row to the detailVC:
            detailVC.meme = MemeCollection.allMemes[indexPath.row]
            
            //Present the view controller:
            navigationController!.pushViewController(detailVC, animated: true)
        }
    }
    
    @IBAction func unwindMemeEditor(segue: UIStoryboardSegue) {
        tableView!.reloadData()
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
}
