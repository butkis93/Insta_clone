//
//  PostViewController.swift
//  InstagramClone
//
//

import UIKit

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    @IBOutlet var chosenImage: UIImageView!
    @IBOutlet var imageDescriptionTextField: UITextField!
    
    var photoSelected: Bool = false
    var error: String = ""
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoSelected = false
        chosenImage.image = UIImage(named: "no_image.png")
        imageDescriptionTextField.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayAlert(title: String, error: String) {
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        chosenImage.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
        photoSelected = true
    }

    @IBAction func chooseImageButtonClicked(sender: AnyObject) {
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = true
        
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    @IBAction func submitButtonClicked(sender: AnyObject) {
        if !photoSelected {
            error = "Please select an image..."
        }
        
        if error != "" {
            displayAlert("Can't post image.", error: error)
        } else {
            // showing an activity indicator while fetching user's account
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            var post: PFObject = PFObject(className: "Posts")
            post["description"] = imageDescriptionTextField.text
            post["username"] = PFUser.currentUser().username
            
            post.saveInBackgroundWithBlock({
                (succeeded: Bool!, error: NSError!) -> Void in
                
                if !succeeded {
                    self.displayAlert("Could not post image.", error: "Try again later.")
                    
                    // stops activity indicator and allows user to control app
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                } else {
                    let imageData = UIImagePNGRepresentation(self.chosenImage.image)
                    let imageFile = PFFile(name: "image.png", data: imageData)
                    post["imageFile"] = imageFile
                    
                    post.saveInBackgroundWithBlock({
                        (succeeded: Bool!, error: NSError!) -> Void in
                        
                        // stops activity indicator and allows user to control app
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        
                        if !succeeded {
                            self.displayAlert("Could not post image.", error: "Try again later.")
                        } else {
                            self.displayAlert("Successful Post!", error: "")
                            
                            self.photoSelected = false
                            self.chosenImage.image = UIImage(named: "no_image.png")
                            self.imageDescriptionTextField.text = ""
                        }
                    })
                }
            })
        }
    }

    /*
     * Logs user out and sends them back to login page.
     */
    @IBAction func logoutButtonClicked(sender: AnyObject) {
        PFUser.logOut()
        self.performSegueWithIdentifier("postToLoginController", sender: self)
    }
    
}
