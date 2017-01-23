//
//  UserTableViewController.swift
//  TomskSoftChat
//
//  Created by ydo on 09/01/2017.
//  Copyright © var7 ydo. All rights reserved.
//

import UIKit

class UserTableViewController: UITableViewController {

    @IBOutlet weak var exitButton: UIBarButtonItem!
    // MARK: Properties
    
    var users = [User]()
    //var userList = [String]()
    //var user: User?
    
    // MARK: Private methods
    
    /*private func loadSampleUserContacts(){
        let user1 = User(name: "user1", id: "1", status: nil)
        let user2 = User(name: "user2", id: "2")
        let user3 = User(name: "user3", id: "3", status: "online")
        
        users += [user1, user2, user3]
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Load the sample data.
        //loadSampleUserContacts()
        
        self.tableView.rowHeight = 90.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // exitChatButton.isEnabled = false
        
        if User.model.name == nil {
            askForNickname()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Outlet action
    
    @IBAction func exitChat(_ sender: UIBarButtonItem) {
        SocketIOManager.sharedInstance.exitChatWithNickname(nickname: User.model.name!) { () -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                User.model.name = nil
                User.model.id = nil
                User.model.status = nil
                self.users = []
                self.tableView.reloadData()
                self.askForNickname()
            })
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "UserTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UserTableViewCell  else {
            fatalError("The dequeued cell is not an instance of UserTableViewCell.")
        }
        
        // Configure the cell...
        
        // Fetches the appropriate meal for the data source layout.
        let user = users[indexPath.row]
        
        cell.userName.text = user.name
        cell.userLogoImage.text = "\(user.name![user.name!.startIndex])".uppercased()
        cell.userStatus.text = user.status
        if (user.status == "offline") {
            cell.userStatus.textColor = .gray
        } else {
            cell.userStatus.textColor = .green
        }
        //drawCircleLabel(cell.userLogoImage)
        
        return cell
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Custom Functions
    
    func askForNickname() {
        let alertController = UIAlertController(title: "SocketChat", message: "Please enter a nickname:", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addTextField{ (textField : UITextField!) -> Void in
            textField.placeholder = "Enter your Nickname"
        }
        
        let joinAction = UIAlertAction(title: "Join", style: UIAlertActionStyle.default) { (action) -> Void in
            
            let textField = alertController.textFields![0] as UITextField
        
            if textField.text?.characters.count == 0 {
                self.askForNickname()
            } else {
                // function checkUsername
               
                User.model.name = textField.text!;
                
                SocketIOManager.sharedInstance.connectToServerWithNickname(nickname: User.model.name!, completionHandler: { (userList) -> Void in
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        print("user list load-> ")
                        
                        if userList != nil {
                            self.users.removeAll()
                            
                            for userInList in userList! {
                                guard let username = userInList["nickname"] else {
                                    fatalError("user should have a nickname")
                                }
                            
                                guard let isConnected = userInList["isConnected"] else {
                                    fatalError("user should have a status")
                                }
                            
                                let status = (isConnected as! Bool) ? "online" : "offline"
                                let userId = (userInList["id"] as! String)
                                let newUser = User(name: username as? String, id: userId, status: status)
                        
                                self.users.insert(newUser, at: 0)
                            }
                            
                            print("users: \(self.users.count)")
                            self.tableView.reloadData()
                            self.tableView.isHidden = false
                            //self.exitChatButton.isEnabled = true
                        }
                    })
                })
            }
        }
        
        alertController.addAction(joinAction)
        present(alertController, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let chatTableViewController = segue.destination as? ChatTableViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        guard let selectedUserCell = sender as? UserTableViewCell else {
            fatalError("Unexpected sender: \(sender)")
        }
        
        guard let indexPath = tableView.indexPath(for: selectedUserCell) else {
            fatalError("The selected cell is not being displayed by the table")
        }
        
        let selectedUser = users[indexPath.row]
        chatTableViewController.recipientUser = selectedUser
        //chatTableViewController.user = user!
    }
}

