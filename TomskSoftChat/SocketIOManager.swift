import UIKit

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    var socket: SocketIOClient = SocketIOClient(socketURL: URL(string: "http://10.0.170.38:3000")!)
    
    override init() {
        super.init()
    }
    
    
    func establishConnection() {
        print("Connect to socket")
        socket.connect()
    }
    
    
    func closeConnection() {
        print("Connect close")
        socket.disconnect()
    }
    
    
    var firstConnect = true
    
    func connectToServerWithNickname(nickname: String, completionHandler: @escaping (_ userList: [[String: AnyObject]]?) -> Void) {
        socket.emit("connectUser", nickname)
        if (firstConnect) {
            firstConnect = false
            socket.on("userList") { ( dataArray, ack) -> Void in
                completionHandler(dataArray[0] as? [[String: AnyObject]])
            }
        }
        //listenForOtherMessages()
    }
    
    func getChat(clientNickname: String, recipientNickname: String, completionHandler: @escaping (_ chatList: [[String: AnyObject]]?) -> Void) {
        socket.emit("getChat", clientNickname, recipientNickname)
        
        socket.off("loadChat")
        socket.on("loadChat") { ( dataArray, ack) -> Void   in
                completionHandler(dataArray[0] as? [[String: AnyObject]])
        }
    }
    
    
    func exitChatWithNickname(nickname: String, completionHandler: () -> Void) {
        socket.emit("exitUser", nickname)
        completionHandler()
    }
    
    
    func sendMessage(message: String, clientNickname: String, recipientNickname: String) {
        socket.emit("chatMessage", clientNickname, message, recipientNickname)
    }
    
    
    func getChatMessage(completionHandler: @escaping (_ messageInfo: [String: AnyObject]) -> Void) {
        socket.on("newChatMessage") { (dataArray, ack) -> Void in
            
            let data = (dataArray[0] as! [[String: AnyObject]])
            
            var messageDictionary = [String: AnyObject]()
            //print(dataArray)
            //print(data)
            
            messageDictionary["nickname"] = data[0]["clientNickname"] as! String as AnyObject?
            messageDictionary["message"] = data[0]["message"] as! String as AnyObject?
            messageDictionary["date"] = data[0]["date"] as! String as AnyObject?
            messageDictionary["recipientNickname"] = data[0]["recipientNickname"] as! String as AnyObject?
            
            completionHandler(data[0])
            //completionHandler((dataArray[0] as? [[String: AnyObject]])!)
        }
    }
    
    
    /*private func listenForOtherMessages() {
        socket.on("userConnectUpdate") { (dataArray, socketAck) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userWasConnectedNotification"), object: dataArray[0] as! [String: AnyObject])
        }
        
        socket.on("userExitUpdate") { (dataArray, socketAck) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userWasDisconnectedNotification"), object: dataArray[0] as! String)
        }
        
        socket.on("userTypingUpdate") { (dataArray, socketAck) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userTypingNotification"), object: dataArray[0] as? [String: AnyObject])
        }
    }
    
    
    func sendStartTypingMessage(nickname: String) {
        socket.emit("startType", nickname)
    }
    
    
    func sendStopTypingMessage(nickname: String) {
        socket.emit("stopType", nickname)
    }*/
}
