import UIKit

class Message: NSObject {
    //MARK: Properties
    
    let user_id: String
    let text: String
    let dialog_id: String
    let date: String?
    
    init(dialog_id: String, text: String, date: String = "", user_id: String = "") {
        self.dialog_id = dialog_id
        self.text = text
        self.date = date
        self.user_id = (user_id != "") ? user_id : User.model.name!
        //self.date = Date(timeIntervalSinceReferenceDate: -123456789.0)
    }
    
    func send() {
        SocketIOManager.sharedInstance.sendMessage(message: self.text, clientNickname: User.model.name!, recipientNickname: self.dialog_id)
    }
    
    /*func simpleDescription() -> String {
        return "A User from server, status: \(status)."
    }*/
}
