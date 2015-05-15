//
//  FeedViewController.swift
//  InstagramClone
//
//

import UIKit

class FeedViewController: UITableViewController {
    
    var descriptions = [String]()
    var users = [String]()
    var images = [UIImage]()
    var imageFiles = [PFFile]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.scrollEnabled = true
        
        var getFollowedUsersQuery = PFQuery(className: "Followers")
        var query = PFQuery(className: "Posts")
        
        getFollowedUsersQuery.whereKey("follower", equalTo: PFUser.currentUser().username)
        getFollowedUsersQuery.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) -> Void in
            
            if error == nil {
                for object in objects {
                    query.whereKey("username", equalTo: object["following"] as String)
                    query.findObjectsInBackgroundWithBlock({
                        (objects: [AnyObject]!, error: NSError!) -> Void in
                        
                        if error == nil {
                            for object in objects {
                                self.descriptions.append(object["description"] as String)
                                self.users.append(object["username"] as String)
                                self.imageFiles.append(object["imageFile"] as PFFile)
                                
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /*
    * Returns the number of rows in the table view.
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    /*
     * Returns the height of the individual cells.
     */
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 300
    }
    
    /*
    * Sets the cell text to the user name.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: PostCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as PostCell
        
        cell.imageDescription.text = descriptions[indexPath.row]
        cell.username.text = users[indexPath.row]
        
        imageFiles[indexPath.row].getDataInBackgroundWithBlock({
            (imageData: NSData!, error: NSError!) -> Void in
            
            if error == nil {
                let image = UIImage(data: imageData)
                cell.postedImage.image = image
            }
        })
        
        return cell
    }
    
}
