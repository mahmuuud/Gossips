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
    @IBOutlet weak var textView: UITextView!
    var _refHandle:DatabaseHandle!
    var placeholderLabel : UILabel!
    var currentUser:User!
    var imageTobePosted=UIImage()
    var imageData:Data!
    var currentChat:Chat!
    var messages:[Message] = []
    var sentMessages:[Message] = []
    var recievedMessages:[Message] = []
    var reciever:User!
    var refHandle:DatabaseHandle!
    var sentMessagenib = UINib(nibName: "ChatTableViewCell", bundle: nil)
    var sentMessagereuse = "ChatTableViewCell"
    var sentMessagenib2 = UINib(nibName: "secondChatTableViewCell", bundle: nil)
    var sentMessagereuse2 = "secondChatTableViewCell"
    var imgSentMessagenib2 = UINib(nibName: "imagesecondTableViewCell", bundle: nil)
    var imgSentMessagereuse2 = "imagesecondTableViewCell"
    var imgtablecellnib = UINib(nibName: "ImageTableViewCell", bundle: nil)
    var imgtablecellreuse = "ImageTableViewCell"
  

    @IBOutlet weak var messagesTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        setupNavBar()
        observeMessagesChanges()
        messagesTableView.register(sentMessagenib, forCellReuseIdentifier: sentMessagereuse)
          messagesTableView.register(sentMessagenib2, forCellReuseIdentifier: sentMessagereuse2)
         messagesTableView.register(imgSentMessagenib2, forCellReuseIdentifier: imgSentMessagereuse2)
             messagesTableView.register(imgtablecellnib, forCellReuseIdentifier: imgtablecellreuse)
          self.messagesTableView.separatorStyle = .none
        textView.layer.cornerRadius = 3
        textView.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Aa"
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (textView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (textView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !textView.text.isEmpty
//        let lastIndex = IndexPath(row: self.messages.count - 1, section: 0)
//        self.messagesTableView.scrollToRow(at: lastIndex, at: .bottom, animated: true)
//
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKey))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKey(){
        view.endEditing(true)
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
            //print("messageData: \(messageData)")
            let message = try? FirebaseDecoder().decode(Message.self, from: messageData)
            //print("message: \(message)")
            if message?.chatId == self.currentChat.id{
                print("found message")
                self.messages.append(message!)
                print("messages count: \(self.messages.count)")
                self.messagesTableView.insertRows(at: [IndexPath(row: self.messages.count-1, section: 0)], with: .automatic)
            }
        }
    }
    

    
    @IBAction func sendButtonTapped(_ sender: Any) {
        let message = Message(chatId: self.currentChat.id, content: self.textView.text!, senderId: self.currentUser.id, recieverId:reciever.id , timeStamp: Date().timeIntervalSinceNow,type: "text")
        let messageJson = try? FirebaseEncoder().encode(message)
        self.textView.text = ""
        print(messageJson!)
        ref.child("messages").childByAutoId().setValue(messageJson)
    }
    
    func setupNavBar(){
        messagesTableView.estimatedRowHeight = 600
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
    
    @IBAction func addPressed(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerController.SourceType.photoLibrary;
            imag.allowsEditing = false
            self.present(imag, animated: true, completion: nil)
        }
    }
    
}

extension ChatViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if (currentUser.id == messages[indexPath.row].recieverId){
            if(messages[indexPath.row].type=="img"){
                let cell = (tableView.dequeueReusableCell(withIdentifier: imgtablecellreuse) as? ImageTableViewCell)!
                let dataOption = NSData(base64Encoded: messages[indexPath.row].content, options: [])
                let image:UIImage=UIImage(data: dataOption! as Data)!
                cell.cellImage.image=image
                return cell
            }
            let cell = (tableView.dequeueReusableCell(withIdentifier: sentMessagereuse) as? ChatTableViewCell)!
             cell.messageLabel?.text = messages[indexPath.row].content
             return cell
        }else{
            if(messages[indexPath.row].type=="img"){
                let cell = (tableView.dequeueReusableCell(withIdentifier: imgSentMessagereuse2) as? imagesecondTableViewCell)!
                let dataOption = NSData(base64Encoded: messages[indexPath.row].content, options: [])
                let image:UIImage=UIImage(data: dataOption! as Data)!
                cell.cellImage.image=image
                return cell
            }
            let cell = (tableView.dequeueReusableCell(withIdentifier: sentMessagereuse2) as? secondChatTableViewCell)!
            
            cell.messageLabel?.text = messages[indexPath.row].content
            return cell
        }
       
       
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}

extension ChatViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let key = UIImagePickerController.InfoKey.originalImage
        self.imageTobePosted = info[key] as! UIImage
        let imageData:Data = self.imageTobePosted.pngData()!
        self.imageData = imageData
        let str = self.imageData.base64EncodedString()
        let message = Message(chatId: self.currentChat.id, content: str, senderId: self.currentUser.id, recieverId:reciever.id , timeStamp: Date().timeIntervalSinceNow,type: "img")
        let messageJson = try? FirebaseEncoder().encode(message)
        ref.child("messages").childByAutoId().setValue(messageJson)
        picker.dismiss(animated: true, completion: nil)
    }
    
}
extension ChatViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
