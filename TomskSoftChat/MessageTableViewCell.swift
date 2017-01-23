//
//  MessageTableViewCell.swift
//  TomskSoftChat
//
//  Created by ydo on 10/01/2017.
//  Copyright © 2017 ydo. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var messageDateLabel: UILabel!
    
    /*lazy var nameLabel: UILabel = {
        let label = UILabel()
       // label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle)
        label.textColor = UIColor(red: 0/255.0, green: 128/255.0, blue: 64/255.0, alpha: 1.0)
        return label
    }()
    
    lazy var bodyLabel: UILabel = {
        let label = UILabel()
       // label.font = UIFont.preferredFont(forTextStyle: UIFontText)
        label.numberOfLines = 0
        return label
    }()*/
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //configureSubviews()
    }
    
    // We won’t use this but it’s required for the class to compile
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
