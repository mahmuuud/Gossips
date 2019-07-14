//
//  ChatViewController.swift
//  Gossips
//
//  Created by mahmoud mohamed on 7/5/19.
//  Copyright © 2019 Robusta. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase

class ChatViewController: UIViewController {
    var ref:DatabaseReference!
    var _refHandle:DatabaseHandle!
    var currentUser:User!
    var currentChat:Chat!
    var messages:[Message] = []
    var sentMessages:[Message] = []
    var recievedMessages:[Message] = []
    var reciever:User!
    var refHandle:DatabaseHandle!
    
    

    @IBOutlet weak var messageTextField: UITextField!

    @IBOutlet weak var messagesTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        setupNavBar()
        observeMessagesChanges()
    }
    
    func observeMessagesChanges(){
        let searchRef = ref.child("messages")
        searchRef.observe(.childAdded) { (snapshot) in
            print("Observingggg")
            if snapshot.value is NSNull{
                print("Error retrieving messages")
                return
            }
            let messageData = snapshot.value!
            print("messageData: \(messageData)")
            let message = try? FirebaseDecoder().decode(Message.self, from: messageData)
            print("message: \(message)")
            if message?.chatId == self.currentChat.id{
                print("found message")
                self.messages.append(message!)
                print("messages count: \(self.messages.count)")
                self.messagesTableView.insertRows(at: [IndexPath(row: self.messages.count-1, section: 0)], with: .automatic)
            }
        }
    }
    

    
    @IBAction func sendButtonTapped(_ sender: Any) {
        let message = Message(chatId: self.currentChat.id, content: messageTextField.text!, senderId: self.currentUser.id, recieverId:reciever.id , timeStamp: Date().timeIntervalSinceNow)
        let messageJson = try? FirebaseEncoder().encode(message)
        self.messageTextField.text = ""
        print(messageJson!)
        ref.child("messages").childByAutoId().setValue(messageJson)
    }
    
    func setupNavBar(){
        var user:User
        if self.currentChat.user1.id == currentUser.id{
            user = currentChat.user2
            self.reciever = currentChat.user2
        }
        else{
            user = currentChat.user1
            self.reciever = currentChat.user1
        }
        navigationItem.title = user.phoneNumber
        self.navigationController?.navigationBar.tintColor = .white
        //        self.navigationController?.navigationBar.backgroundColor = .darkGray
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.barTintColor = .black
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        self.navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        self.navigationController?.navigationBar.barStyle = .black
    }
    
    
}

extension ChatViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let messageSnapshot = messages[indexPath.row]
//        let message = messageSnapshot.value as! [String:String]
        let cell = UITableViewCell()
        cell.textLabel?.text = messages[indexPath.row].content
        return cell
        
    }
    
    
}

