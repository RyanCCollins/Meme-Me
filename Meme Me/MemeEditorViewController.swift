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
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    //Define Global Vars:
    var imagePickerController: UIImagePickerController!
    var memedImage: UIImage!
    var editMeme: Meme?
    var editMemeIndex: Int?

    var fontAttributes: FontAttributes!
    
    var selectedTextField: UITextField?
    var userIsEditing = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Congifure the UI
        initUIState()
    }
    
    func initUIState() {
        
        //Create an array of text fields for configurations
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
            //Set default text/font attributes if new meme:
            fontAttributes = FontAttributes()
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
                NSFontAttributeName: UIFont(name: fontAttributes.fontName, size: fontAttributes.fontSize)!,
                NSStrokeWidthAttributeName : -4.0
            ]
            textField.defaultTextAttributes = memeTextAttributes
            textField.textAlignment = .Center
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        
        //Subscribe to keyboard & shake notifications:
        subscribeToKeyboardNotification()
        subscribeToShakeNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        //unsubscribe to keyboard notification:
        unsubsribeToKeyboardNotification()
        unsubsribeToShakeNotification()
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
    
    //Select an image from the camera:
    @IBAction func pickImageFromCamera(sender: AnyObject) {
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    //Alert the user:
    func alertUser(title: String! = "Title", message: String?, actions: [UIAlertAction]) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        for action in actions {
            ac.addAction(action)
        }
        presentViewController(ac, animated: true, completion: nil)
    }
    
    //Clear the view if user presses cancel
    func clearView() {
        imageView.image = nil
        topText.text = nil
        bottomText.text = nil
    }
    
    //Save the meme:
    @IBAction func save(sender: AnyObject) -> Void {
        //Create the meme and save it to our Meme Model:
        
        //If all items are filled out:
        if userCanSave() {
            //If you are editing a meme, update it, if new, save it:
            let meme = Meme(topText: topText.text, bottomText: bottomText.text, originalImage: imageView.image, memedImage: generateMemedImage(), fontAttributes: fontAttributes)
            if userIsEditing {
                if let editMeme = editMeme {
                        MemeCollection.update(atIndex: MemeCollection.indexOf(editMeme), withMeme: meme)
                    }
                performSegueWithIdentifier("unwindMemeEditor", sender: sender)
            } else {
                MemeCollection.add(meme)
                dismissViewControllerAnimated(true, completion: nil)
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
    
    //If no memes, clear the view, otherwise dismiss the view:
    @IBAction func didTapCancel(sender: UIBarButtonItem) {
        if MemeCollection.allMemes.count == 0 {
            clearView()
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
            //Launch color picker in popover view:
            let popoverVC = segue.destinationViewController as! SwiftColorPickerViewController
            popoverVC.delegate = self
            popoverVC.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverVC.popoverPresentationController!.delegate = self
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
    
    //# -- Mark: Popover delegate func
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }

    //# -- Mark: SwiftColorPickerDelegate function:
    func colorSelectionChanged(selectedColor color: UIColor) {
        fontAttributes.fontColor = color
        configureTextFields([topText, bottomText])
    }
    
    //#--MARK: Respond to shake notification:
    func alertForReset() {
        let ac = UIAlertController(title: "Reset?", message: "Are you sure you want to reset the font size and type?", preferredStyle: .Alert)
        let resetAction = UIAlertAction(title: "Reset", style: .Default, handler: { Void in
            //Reset to default values and update the Meme's font:
            self.setFontAttributeDefaults(40.0, fontName: "HelveticaNeue-CondensedBlack", fontColor: UIColor.whiteColor())
            self.updateMemeFont()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        ac.addAction(resetAction)
        ac.addAction(cancelAction)
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func updateMemeFont(){
        //update the MemeEditor font and reconfigure the view:
        configureTextFields([topText, bottomText])
    }
    
    func setFontAttributeDefaults(fontSize: CGFloat = 40.0, fontName: String = "HelveticaNeue-CondensedBlack", fontColor: UIColor = UIColor.whiteColor()){
        fontAttributes.fontSize = CGFloat(fontSize)
        fontAttributes.fontName = fontName
        fontAttributes.fontColor = fontColor
    }
}

//#-- Extend UIImagePickerDelegate Methods
extension MemeEditorViewController {
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
}

//#-- Extend the UITextFieldDelegate Methods for MemeEditorViewController
extension MemeEditorViewController {
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
            //Save button disabled:
            saveButton.enabled = false
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //Reset view origin when keyboard hides:
        if -view.frame.origin.y > 0 {
            view.frame.origin.y = 0
            //Enable savebutton if userCanSave:
            saveButton.enabled = userCanSave()
        }
    }
}


//#--Shake to reset Extension:
extension UIViewController {
    //#--MARK: Subsribe to shake notifications:
    func subscribeToShakeNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "alertForReset", name: "shake", object: nil)
    }
    
    func unsubsribeToShakeNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "shake", object: nil)
    }
    
    override public func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    //Handle motion events:
    override public func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == UIEventSubtype.MotionShake {
            NSNotificationCenter.defaultCenter().postNotificationName("shake", object: self)
        }
    }
}