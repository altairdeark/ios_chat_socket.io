//
//  ChatTableViewController.swift
//  TomskSoftChat
//
//  Created by ydo on 10/01/2017.
//  Copyright © 2017 ydo. All rights reserved.
//

import UIKit

class ChatTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var backBarButton: UIBarButtonItem!
    @IBOutlet weak var textEditView: UIView!
    
    var chatMessages = [Message]()
    
    //var user: User!
    var recipientUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Delegate
        
        //messageTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatTableViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatTableViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        super.navigationItem.title = recipientUser.name
        
        configureTableView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SocketIOManager.sharedInstance.getChatMessage { (messageInfo) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                
                let message = self.loadMessage(messageInfo: messageInfo)
                
                print("\(self.recipientUser.name == message.dialog_id),  \(self.recipientUser.name == message.user_id) && \(User.model.name == message.dialog_id), \(User.model.name == message.user_id)")
                
                
                
                if ((self.recipientUser.name == message.dialog_id || self.recipientUser.name == message.user_id) && (User.model.name == message.dialog_id || User.model.name == message.user_id)) {
                
                    if (self.recipientUser.name == User.model.name && message.dialog_id != message.user_id) {
                        return
                    }
                    
                    self.chatMessages += [message]
                    self.reloadTable()
                }
            })
        }
        loadChat()
    }
    
    // MARK: IBAction Methods
    
    @IBAction func sendMessage(_ sender: AnyObject) {
        let message = Message(dialog_id: recipientUser.name!, text: messageTextField.text!)
        message.send()
    }
    
    @IBAction func goBackToContactList(_ sender: UIBarButtonItem) {
        if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The ChatViewTableController is not inside a navigation controller.")
        }
        //dismiss(animated: true, completion: nil)
    }
    
    // MARK: Custom Methods
    
    func configureTableView() {
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.estimatedRowHeight = 100.0
        chatTableView.rowHeight = UITableViewAutomaticDimension
        chatTableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func loadMessage(messageInfo: [String: AnyObject]) -> Message
    {
        guard let user_id = messageInfo["clientNickname"] else {
            fatalError("user should have a nickname")
        }
        
        guard let text = messageInfo["message"] else {
            fatalError("message missing")
        }
        
        guard let date = messageInfo["date"] else {
            fatalError("date missing")
        }
        
        guard let dialog_id = messageInfo["recipientNickname"] else {
            fatalError("user should have a nickname")
        }
        
        return Message(dialog_id: dialog_id as! String, text: text as! String, date: date as! String, user_id: user_id as! String)
    }
    
    func loadChat() -> Void {
        
        print("Load Chat")
        
        SocketIOManager.sharedInstance.getChat(clientNickname: User.model.name!, recipientNickname: recipientUser.name!, completionHandler: { (chatList) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if chatList != nil {
                    self.chatMessages = [];
                
                    for messageInfo in chatList!{
                        let message = self.loadMessage(messageInfo: messageInfo)
                        self.chatMessages += [message]
                    }
                    
                    print("loaded msg: \(self.chatMessages.count)")
                    
                    self.reloadTable()
                }
            })
        })
    }
    
    // MARK: UITableView Delegate and Datasource Methods
    
    func reloadTable() {
        chatTableView.reloadData()
        
        if (chatMessages.count != 0) {
            let indexPath = IndexPath(row: chatMessages.count - 1, section: 0)
        
            chatTableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idMessageTableViewCell", for: indexPath) as! MessageTableViewCell

        let message = chatMessages[indexPath.row]
        
        if (message.user_id == User.model.name) {
            cell.messageTextLabel.textAlignment = .right
            cell.messageDateLabel.textAlignment = .right
        } else {
            cell.messageTextLabel.textAlignment = .left
            cell.messageDateLabel.textAlignment = .left
        }
        
        cell.messageDateLabel.text = message.date
        cell.messageTextLabel.text = message.text
        
        return cell
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    /*func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print("editing")
        return true
    }*/
    
    /*func textFieldDidEndEditing(_ textField: UITextField) {
        // Hide the keyboard.
        textField.resignFirstResponder()
    }*/
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            //    print(self.chatTableView.frame.origin)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height            }
        }
    }
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let userViewController = segue.destination as? UserViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        /*guard let selectedUserCell = sender as? UserTableViewCell else {
            fatalError("Unexpected sender: \(sender)")
        }*/
        
        userViewController.user = recipientUser
    }
    
    
}
