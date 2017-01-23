import UIKit

class User: NSObject {
    
    static var model = User()
    
    //MARK: Properties
    
    var name: String?
    var id: String?
    var status: String?

    init(name: String? =  nil, id: String? = nil, status: String? = "offline") {
        self.name = name
        self.id = id
        self.status = status
    }

    func simpleDescription() -> String {
        return "A User from server, status: \(status)."
    }

}
