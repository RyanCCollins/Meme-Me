//
//  MemeEditorViewController.swift
//  Meme Me
//
//  Created by Ryan Collins on 9/28/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var imagePickerController: UIImagePickerController!
    var memedImage: UIImage!
    var selectedTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textFieldArray = [topText, bottomText]
        configureTextFields(textFieldArray)

        //Disable the Share button:
        shareButton.enabled = false
        cancelButton.enabled = false
    }
    
    func configureTextFields(textFields: [UITextField!]){
        let memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : 4.0
        ]
        
        for textField in textFields{
            print(textField.text)
        //Configure and position the top textfield
            
            textField.textAlignment = .Center
            textField.delegate = self
            textField.defaultTextAttributes = memeTextAttributes
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
            
            self.presentViewController(imagePickerController, animated: true, completion: nil)
        }
    }
    
    //Select an image from the camera:
    @IBAction func pickImageFromCamera(sender: AnyObject) {
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    //UIImagePickerDelegate methods:
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        imageView.image = image
        
        //Enable share & cancel buttons once image is returned:
        shareButton.enabled = true
        cancelButton.enabled = true
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        //dismiss viewcontroller
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //UITextFieldDelegate Methods:
    func textFieldDidBeginEditing(textField: UITextField) {
        selectedTextField = textField
        textField.clearsOnBeginEditing = true
    }
    
    //sets the TextField size:
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        UIView.animateWithDuration(0.1, animations: {
            textField.invalidateIntrinsicContentSize()
        })
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        selectedTextField = nil
        configureTextFields([textField])
        textField.resignFirstResponder()
        return true
    }
    
    //Hide keyboard when view is tapped:
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        //slide the view up when keyboard appears, using notifications:
        if selectedTextField == bottomText && self.view.frame.origin.y == 0.0 {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //Reset view origin when keyboard hides:
        if -self.view.frame.origin.y > 0 {
            self.view.frame.origin.y = 0
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
    
    //Save the meme:
    func save() {
        //Create the meme and save it to our Meme Model:
        //TODO: setup checks to make sure that no objects are nil
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imageView.image, memedImage: memedImage)
        print(meme.bottomText)
    }
    
    func generateMemedImage() -> UIImage {
        //TODO: hide toolbars & Navbars
        //render view to an image:
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //TODO: Show toolbars and navbars:
        
        return memedImage
    }
    
    @IBAction func shareTapped(sender: UIBarButtonItem) {
        //TODO: provide share code
        let imageToShare = generateMemedImage()
        let activityItems = [imageToShare]
        let ac = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        presentViewController(ac, animated: true, completion: {
            self.save()
            //self.dismissViewControllerAnimated(true, completion: nil)
        })
        
    }
    
    @IBAction func cancelTapped(sender: UIBarButtonItem) {
        //TODO: cancel sharing
    }
    
}

