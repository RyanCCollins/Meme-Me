//
//  MemeEditorViewController.swift
//  Meme Me
//
//  Created by Ryan Collins on 9/28/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, SwiftColorPickerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /* Global variable definitions */
    var imagePickerController: UIImagePickerController!
    var memedImage: UIImage!
    var editMeme: Meme?
    var fontAttributes: FontAttributes!
    var selectedTextField: UITextField?
    var userIsEditing = false
    
    //#-MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //Congifure the UI to its default state */
        setDefaultUIState()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        /* Disable camera button if no camera is available */
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        
        subscribeToKeyboardNotification()
        subscribeToShakeNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        unsubsribeToKeyboardNotification()
        unsubsribeToShakeNotification()
    }
    
    /* Hide status bar to avoid bug where status bar shows when imageview pushed up by keyboard */
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    /* Set the state of the User Interface to editing or creating
    If you are editing a Meme, then configure and set the appropriate fields
    Otherwise, configure default state for text fields */
    func setDefaultUIState() {
        let textFieldArray = [topText, bottomText]
        
        /* Set the meme to edit if there is an editMeme */
        if let editMeme = editMeme {
            navBar.topItem?.title = "Edit your Meme"
            
            topText.text = editMeme.topText
            bottomText.text = editMeme.bottomText
            imageView.image = editMeme.originalImage
            
            userIsEditing = true
            fontAttributes = editMeme.fontAttributes
            configureTextFields(textFieldArray)
        } else {
            //Set the title if creating a Meme */
            navBar.topItem?.title = "Create a Meme"
            fontAttributes = FontAttributes()
            configureTextFields(textFieldArray)
        }
        
        /* Hide or Show the buttons based on whether the user is editing */
        shareButton.enabled = userIsEditing
        cancelButton.enabled = userIsEditing
        saveButton.enabled = userIsEditing
    }
    
    /* Pass an array of text fields and set the default text attributes for each */
    func configureTextFields(textFields: [UITextField!]){
        for textField in textFields{
            textField.delegate = self
            
            /* Define default Text Attributes */
            let memeTextAttributes = [
                NSStrokeColorAttributeName: UIColor.blackColor(),
                NSForegroundColorAttributeName: fontAttributes.fontColor,
                NSFontAttributeName: UIFont(name: fontAttributes.fontName, size: fontAttributes.fontSize)!,
                NSStrokeWidthAttributeName : -4.0
            ]
            textField.defaultTextAttributes = memeTextAttributes
            textField.textAlignment = .Center
        }
    }
    
    /* Check if the photo album is available
    then Select and return an image from the photo library */
    @IBAction func selectImageFromCameraRoll(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {

            /* Initialize and present the imagepicker */
            imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePickerController.allowsEditing = false
            
            presentViewController(imagePickerController, animated: true, completion: nil)
        }
    }
    
    /* If available, select an image from the camera */
    @IBAction func pickImageFromCamera(sender: AnyObject) {
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    /* Alert the user if something is missing from the meme when they try to save */
    func alertUser(title: String! = "Title", message: String?, actions: [UIAlertAction]) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        for action in actions {
            ac.addAction(action)
        }
        presentViewController(ac, animated: true, completion: nil)
    }
    
    /* Clear the view if user presses cancel */
    func clearView() {
        imageView.image = nil
        topText.text = nil
        bottomText.text = nil
    }
    
    /* Create the meme and save it to the Meme Model */
    @IBAction func saveMeme(sender: AnyObject) -> Void {
        
        /* Check If all items are filled out */
        if userCanSave() {
            
            /* Initialize a new meme to save or update */
            let meme = Meme(topText: topText.text, bottomText: bottomText.text, originalImage: imageView.image, memedImage: generateMemedImage(), fontAttributes: fontAttributes)
            
            /* If you are editing a meme, update it, if new, save it */
            if userIsEditing {
                
                /* Unwrap then update the meme if there is one to update */
                if let editMeme = editMeme {
                        MemeCollection.update(atIndex: MemeCollection.indexOf(editMeme), withMeme: meme)
                    }
                /* Unwind to table view once meme is updated */
                performSegueWithIdentifier("unwindMemeEditor", sender: sender)
                
            } else {
                /* Add the Meme if user is not editing */
                MemeCollection.add(meme)
                dismissViewControllerAnimated(true, completion: nil)
            }
        } else {
            /* Alert user if something is missing and you can't save */
            let okAction = UIAlertAction(title: "Save", style: .Default, handler: { Void in
                self.topText.text = ""
                self.bottomText.text = ""
                return
            })
            let editAction = UIAlertAction(title: "Edit", style: .Default, handler: nil)
            
            alertUser(message: "Your meme is missing something.", actions: [okAction, editAction])
        }
    }
    
    /* Test to see whether the user can save or not */
    func userCanSave() -> Bool {
        if topText.text == nil || bottomText.text == nil || imageView.image == nil {
            return false
        } else {
            return true
        }
    }
    
    func generateMemedImage() -> UIImage {
        /* Hide everything but the image */
        hideNavItems(true)
        
        /* render view to an image */
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        /* Show all views that were hidden */
        hideNavItems(false)
        
        return memedImage
    }
    
    private func hideNavItems(hide: Bool){
        navigationController?.setNavigationBarHidden(hide, animated: false)
        navBar.hidden = hide
        bottomToolbar.hidden = hide
    }
    
    /* Present the ActivityViewController programmatically to share a Meme */
    @IBAction func didTapShare(sender: UIBarButtonItem) {
        
        let ac = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        ac.completionWithItemsHandler = { activity, success, items, error in
            if success {
                self.saveMeme(self)
            }
        }
        presentViewController(ac, animated: true, completion: nil)
    }
    
    /* If no memes, clear the view, otherwise dismiss the view */
    @IBAction func didTapCancel(sender: UIBarButtonItem) {
        if MemeCollection.allMemes.count == 0 {
            clearView()
        }else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    //# -- Mark: Present popover views
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fontPopoverSegue" {
            let popoverVC = segue.destinationViewController as! TextSizePopoverViewController
            popoverVC.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverVC.popoverPresentationController!.delegate = self
            popoverVC.fontAttributes = fontAttributes
        }
        
        if segue.identifier == "colorPickerPopoverSegue" {
            /* Launch color picker in popover view */
            let popoverVC = segue.destinationViewController as! SwiftColorPickerViewController
            popoverVC.delegate = self
            popoverVC.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverVC.popoverPresentationController!.delegate = self
        }
        
    }
    
    /* Popover delegate method */
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }

    /* SwiftColorPickerDelegate function */
    func colorSelectionChanged(selectedColor color: UIColor) {
        fontAttributes.fontColor = color
        configureTextFields([topText, bottomText])
    }
    
    /* Respond to shake notifications and alert to reset text fields to default */
    func alertForReset() {
        let ac = UIAlertController(title: "Reset?", message: "Are you sure you want to reset the font size and type?", preferredStyle: .Alert)
        let resetAction = UIAlertAction(title: "Reset", style: .Default, handler: { Void in
            /* Reset to default values and update the Meme's font */
            self.setFontAttributeDefaults(40.0, fontName: "HelveticaNeue-CondensedBlack", fontColor: UIColor.whiteColor())
            self.updateMemeFont()
        })
        
        /* Alert user with reset and cancel actions */
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        ac.addAction(resetAction)
        ac.addAction(cancelAction)
        presentViewController(ac, animated: true, completion: nil)
    }
    
    /* Update the MemeEditor font and reconfigure the view */
    func updateMemeFont(){
        configureTextFields([topText, bottomText])
    }
    
    /* Set the default font attributes */
    func setFontAttributeDefaults(fontSize: CGFloat = 40.0, fontName: String = "HelveticaNeue-CondensedBlack", fontColor: UIColor = UIColor.whiteColor()){
        fontAttributes.fontSize = CGFloat(fontSize)
        fontAttributes.fontName = fontName
        fontAttributes.fontColor = fontColor
    }
}

//# -- MARK Extend UIImagePickerDelegate Methods for MemeEditorViewController
extension MemeEditorViewController {
    
   /* UIImagePickerDelegate methods */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        dismissViewControllerAnimated(true, completion: nil)
        imageView.image = image
        
        /* Enable share & cancel buttons once image is returned */
        shareButton.enabled = userCanSave()
        saveButton.enabled = userCanSave()
        cancelButton.enabled = true
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

//#-MARK: Extension for the UITextFieldDelegate and Keyboard Notification Methods for MemeEditorViewController
extension MemeEditorViewController {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        selectedTextField = textField
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }
    
    /* Configure and deselect text fields when return is pressed */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        selectedTextField = nil
        configureTextFields([textField])
        
        /* Enable save button if fields are filled and resign first responder */
        saveButton.enabled = userCanSave()
        
        textField.resignFirstResponder()
        return true
    }
    
    /* Suscribe the view controller to the UIKeyboardWillShowNotification */
    func subscribeToKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /* Unsubscribe the view controller to the UIKeyboardWillShowNotification */
    func unsubsribeToKeyboardNotification(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    /* Hide keyboard when view is tapped */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        /* Enable save button if fields are filled out  */
        saveButton.enabled = userCanSave()
        configureTextFields([topText, bottomText])
    }
    
    func keyboardWillShow(notification: NSNotification) {
        /* slide the view up when keyboard appears, using notifications */
        if selectedTextField == bottomText && view.frame.origin.y == 0.0 {
            
            view.frame.origin.y = -getKeyboardHeight(notification)
            saveButton.enabled = false
            
        }
    }
    
    /* Reset view origin when keyboard hides */
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
        saveButton.enabled = userCanSave()
    }
    
    /* Get the height of the keyboard from the user info dictionary */
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
}


//#-MARK:Shake to reset Extension of UIViewController:
extension UIViewController {
    
    /* Subsribe to shake notifications */
    func subscribeToShakeNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "alertForReset", name: "shake", object: nil)
    }
    
    /* Unsubsribe to shake notifications */
    func unsubsribeToShakeNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "shake", object: nil)
    }
    
    /* Allow view to become first responder to respond to shake notifications */
    override public func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    /* Handle motion events and respond to shake notification */
    override public func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == UIEventSubtype.MotionShake {
            NSNotificationCenter.defaultCenter().postNotificationName("shake", object: self)
        }
    }
}