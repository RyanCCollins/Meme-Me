//
//  MemeEditorViewController.swift
//  Meme Me
//
//  Created by Ryan Collins on 9/28/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

enum ButtonState {
    case Cancel
    case Save
    case Editing
}

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, SwiftColorPickerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    //Define Global Vars:
    var imagePickerController: UIImagePickerController!
    var memedImage: UIImage!
    var editMeme: Meme?
    var selectedTextField: UITextField?
    var userIsEditing = false
    var fontAttributes: FontAttributes!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Congifure the UI
        let textFieldArray = [topText, bottomText]
        
        //Set delegate of text fields:
        for textField in textFieldArray {
            textField.delegate = self
        }
        
        //Set the meme to edit if there is an editMeme:
        if let editMeme = editMeme {
            topText.text = editMeme.topText
            bottomText.text = editMeme.bottomText
            imageView.image = editMeme.originalImage
            userIsEditing = true
            fontAttributes = editMeme.fontAttributes
            configureTextFields(textFieldArray)
        } else {
            fontAttributes = FontAttributes()
            fontAttributes.fontColor = UIColor.whiteColor()
            fontAttributes.fontSize = 40.0
            configureTextFields(textFieldArray)
        }
        
        //Hide/Show the buttons:
        shareButton.enabled = userIsEditing
        cancelButton.enabled = userIsEditing
        saveButton.enabled = userIsEditing
    }
    
    func configureTextFields(textFields: [UITextField!]){
        for textField in textFields{
            
            //Define Default Text Attributes:
            let memeTextAttributes = [
                NSStrokeColorAttributeName: UIColor.blackColor(),
                NSForegroundColorAttributeName: fontAttributes.fontColor,
                NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: fontAttributes.fontSize)!,
                NSStrokeWidthAttributeName : -4.0
            ]
            textField.defaultTextAttributes = memeTextAttributes
            textField.textAlignment = .Center
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        
        //Subscribe to keyboard notifications:
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        //unsubscribe to keyboard notification:
        unsubsribeToKeyboardNotification()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Select an image from the photo library:
    @IBAction func selectImage(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {

            //initialize the imagepicker:
            imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePickerController.allowsEditing = false
            
            presentViewController(imagePickerController, animated: true, completion: nil)
        }
    }
    

    @IBAction func pickImageFromCamera(sender: AnyObject) {
        //Select an image from the camera:
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    //# -- MARK: UIImagePickerDelegate methods:
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        dismissViewControllerAnimated(true, completion: nil)
        imageView.image = image
        
        //Enable share & cancel buttons once image is returned:
        shareButton.enabled = userCanSave()
        saveButton.enabled = userCanSave()
        cancelButton.enabled = true
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        //dismiss viewcontroller
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //# -- MARK: UITextFieldDelegate Methods:
    func textFieldDidBeginEditing(textField: UITextField) {
        selectedTextField = textField
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        selectedTextField = nil
        configureTextFields([textField])
        
        //Enable save button if fields are filled:
        saveButton.enabled = userCanSave()
        
        textField.resignFirstResponder()
        return true
    }
    
    //Hide keyboard when view is tapped:
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        //Enable save button if fields are filled:
        saveButton.enabled = userCanSave()
        configureTextFields([topText, bottomText])
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        //slide the view up when keyboard appears, using notifications:
        if selectedTextField == bottomText && view.frame.origin.y == 0.0 {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //Reset view origin when keyboard hides:
        if -view.frame.origin.y > 0 {
            view.frame.origin.y = 0
        }
    }
    
    //Suscribe the view controller to the UIKeyboardWillShowNotification:
    func subscribeToKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //Unsubscribe the view controller to the UIKeyboardWillShowNotification:
    func unsubsribeToKeyboardNotification(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //Get the height of the keyboard from the userinfo dictionary:
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    //Alert the user:
    func alertUser(title: String! = "Title", message: String?, actions: [UIAlertAction]) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        for action in actions {
            ac.addAction(action)
        }
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func clearMeme() {
        imageView.image = nil
        topText.text = nil
        bottomText.text = nil
    }
    
    //Save the meme:
    @IBAction func save(sender: AnyObject) -> Void {
        //Create the meme and save it to our Meme Model:
        //TODO: setup checks to make sure that no objects are nil
        
        //If all items are filled out:
        if userCanSave() {
            //If you are editing a meme, update it, if new, save it:
            if userIsEditing {
                if let editMeme = editMeme {
                    editMeme.updateMeme(topText.text!, bottomText: bottomText.text!, originalImage: imageView.image!, memedImage: generateMemedImage(), fontAttributes: fontAttributes)
                }
            } else {
                let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imageView.image!, memedImage: generateMemedImage(), fontAttributes: fontAttributes)
                meme.saveMeme()
            }
        } else {
            let okAction = UIAlertAction(title: "Save", style: .Default, handler: { Void in
                self.topText.text = ""
                self.bottomText.text = ""
                return
            })
            let editAction = UIAlertAction(title: "Edit", style: .Default, handler: nil)
            
            alertUser(message: "Your meme is missing something.", actions: [okAction, editAction])
        }

        // Add meme to Meme's array in the AppDelegate:
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userCanSave() -> Bool {
        if topText.text == nil || bottomText.text == nil || imageView.image == nil {
            return false
        } else {
            return true
        }
    }
    
    func generateMemedImage() -> UIImage {
        //Hide everything but the image:
        navItemsHidden(areHidden: true)
        
        //render view to an image:
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Show all views that were hidden:
        navItemsHidden(areHidden: false)
        
        return memedImage
    }
    
    private func navItemsHidden(areHidden hide: Bool){
        navigationController?.setNavigationBarHidden(hide, animated: false)
        topToolbar.hidden = hide
        bottomToolbar.hidden = hide
    }
    
    @IBAction func didTapShare(sender: UIBarButtonItem) {
        //Present the ActivityViewController Programmatically:
        let ac = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        ac.completionWithItemsHandler = { activity, success, items, error in
            if success {
                self.save(self)
            }
        }
        presentViewController(ac, animated: true, completion: nil)
    }
    
    @IBAction func didTapCancel(sender: UIBarButtonItem) {
        if Meme.countMemes() == 0 {
            clearMeme()
        }else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    //# -- Mark: present various popover Views:
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fontPopoverSegue" {
            let popoverVC = segue.destinationViewController as! TextSizePopoverViewController
            popoverVC.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverVC.popoverPresentationController!.delegate = self
            popoverVC.fontAttributes = fontAttributes
        }
        
        if segue.identifier == "colorPickerPopoverSegue" {
            //TODO: Add color picker:
                        print("Pressed")
            let popoverVC = segue.destinationViewController as! SwiftColorPickerViewController
            popoverVC.delegate = self
            popoverVC.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverVC.popoverPresentationController!.delegate = self
        }
    }
    
    //# -- Mark: Popover delegate func
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }

    //# -- Mark: SwiftColorPickerDelegate function:
    func colorSelectionChanged(selectedColor color: UIColor) {
        fontAttributes.fontColor = color
        configureTextFields([topText, bottomText])
    }
}

