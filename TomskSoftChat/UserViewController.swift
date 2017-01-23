//
//  UserViewController.swift
//  TomskSoftChat
//
//  Created by ydo on 09/01/2017.
//  Copyright © 2017 ydo. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {

    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userStatusLabel: UILabel!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set up views if editing an existing Meal.
        if let user = user {
            userIdLabel.text = user.id
            userNameLabel.text = user.name
            userStatusLabel.text = user.status
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

