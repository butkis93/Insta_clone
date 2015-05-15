//
//  ViewController.swift
//  InstagramClone
//
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var userPromptLabel: UILabel!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var otherOptionLabel: UILabel!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var signUpActive: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        println(PFUser.currentUser())
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            self.performSegueWithIdentifier("signInToUserTable", sender: self)
        }
    }
    
    /*
     * Hides navigation bar on this controller.
     */
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    /*
     * Displays navigation bar once controller is exited.
     */
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
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

    @IBAction func signUpButtonClicked(sender: AnyObject) {
        var error = ""
        
        if (usernameTextField.text == "" || passwordTextField.text == "") {
            error = "Please enter a username and password"
        }
        
        // checking to see if user submitted a username AND a password
        if (error != "") {
            displayAlert("Error In Form.", error: error)
        } else {
            var user = PFUser()
            user.username = usernameTextField.text
            user.password = passwordTextField.text
            
            // showing an activity indicator while fetching user's account
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            if signUpActive {
                user.signUpInBackgroundWithBlock({
                    (succeeded: Bool!, signUpError: NSError!) -> Void in
                    
                    // stops activity indicator and allows user to control app
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if signUpError == nil {
                        self.performSegueWithIdentifier("signInToUserTable", sender: self)
                        println("signed up")
                    } else {
                        if let errorString = signUpError.userInfo?["error"] as? NSString {
                            error = errorString
                        } else {
                            error = "Please try again later."
                        }
                        
                        self.displayAlert("Could Not Sign Up.", error: error)
                    }
                })
            } else {
                PFUser.logInWithUsernameInBackground(usernameTextField.text, password: passwordTextField.text, block: {
                    (user: PFUser!, signUpError: NSError!) -> Void in
                    
                    // stops activity indicator and allows user to control app
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if signUpError == nil {
                        self.performSegueWithIdentifier("signInToUserTable", sender: self)
                        println("logged in")
                    } else {
                        if let errorString = signUpError.userInfo?["error"] as? NSString {
                            error = errorString
                        } else {
                            error = "Please try again later."
                        }
                        
                        self.displayAlert("Could Not Log In.", error: error)
                    }
                })
            }
        }
    }

    @IBAction func loginButtonClicked(sender: AnyObject) {
        if signUpActive {
            signUpActive = false
            
            userPromptLabel.text = "use form below to login."
            signUpButton.setTitle("Login", forState: UIControlState.Normal)
            otherOptionLabel.text = "Not registered?"
            loginButton.setTitle("Sign Up", forState: UIControlState.Normal)
        } else {
            signUpActive = true
            
            userPromptLabel.text = "use form below to register."
            signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
            otherOptionLabel.text = "Already registered?"
            loginButton.setTitle("Login", forState: UIControlState.Normal)
        }
    }
    
}












