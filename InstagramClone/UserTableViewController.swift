//
//  UserTableViewController.swift
//  InstagramClone
//
//

import UIKit

class UserTableViewController: UITableViewController {
    
    var users = [String]()
    var following = [Bool]()
    var refresher: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUsers()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "refreshing...")
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     * Updates the users in the table view.
     */
    func updateUsers() {
        var query = PFUser.query()
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) -> Void in
            
            self.users.removeAll(keepCapacity: true)
            
            // adds all usernames in database to 'users' array
            for object in objects {
                var user: PFUser = object as PFUser
                var isFollowing: Bool = false
                
                if user.username != PFUser.currentUser().username {
                    self.users.append(user.username)
                    
                    // creating a query to the followers database
                    var query = PFQuery(className: "Followers")
                    query.whereKey("follower", equalTo: PFUser.currentUser().username)
                    query.whereKey("following", equalTo: user.username)
                    
                    // deleting the objects from followers database
                    query.findObjectsInBackgroundWithBlock({
                        (objects: [AnyObject]!, error: NSError!) -> Void in
                        
                        if error == nil {
                            for object in objects {
                                isFollowing = true
                            }
                            
                            self.following.append(isFollowing)
                            self.tableView.reloadData()  // refreshing table view data
                        } else {
                            println(error)
                        }
                        
                        self.refresher.endRefreshing()
                    })
                }
            }
        })
    }
    
    /*
     * Called to refresh contents when user pulls to refresh.
     */
    func refresh() {
       println("refreshed")
        updateUsers()
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
     * Sets the cell text to the user name.
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        if following.count > indexPath.row && following[indexPath.row] {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        
        cell.textLabel?.text = users[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if cell.accessoryType == UITableViewCellAccessoryType.Checkmark {
            cell.accessoryType = UITableViewCellAccessoryType.None
            
            // creating a query to the followers database
            var query = PFQuery(className: "Followers")
            query.whereKey("follower", equalTo: PFUser.currentUser().username)
            query.whereKey("following", equalTo: cell.textLabel?.text)
            
            // deleting the objects from followers database
            query.findObjectsInBackgroundWithBlock({
                (objects: [AnyObject]!, error: NSError!) -> Void in
                
                if error == nil {
                    for object in objects {
                        object.deleteInBackground()
                    }
                } else {
                    println(error)
                }
            })
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            var following = PFObject(className: "Followers")
            following["following"] = cell.textLabel?.text
            following["follower"] = PFUser.currentUser().username
        
            following.saveInBackground()
        }
    }
    
}
