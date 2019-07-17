//
//  FriendsViewController.swift
//  Gossips
//
//  Created by mahmoud mohamed on 7/8/19.
//  Copyright © 2019 Robusta. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase

class FriendsViewController: UIViewController {

    @IBOutlet weak var friendsListTableView: UITableView!
    let friendCellNib = UINib(nibName: "FriendsListTableViewCell", bundle: nil)
    let friendCellReuseId = "FriendsListTableViewCell"
    var currentUser:User!
    var isLoggedIn:Bool?
    var ref:DatabaseReference!
    var chats:[Chat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        setCurrentUser()
        observeFriendListChanges()
        configViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBar()
    }
    
    func observeFriendListChanges(){
        ref.child("chats").observe(.childAdded) { (snapshot) in
            if snapshot.value is NSNull{
                print("Error retrieving chats 🌑")
                return
            }
            let chatData = (snapshot.value )
            print("chat data: \(chatData)")
            let chat = try? FirebaseDecoder().decode(Chat.self, from: chatData!)
            print("chat added: \(chat)")
            if chat?.user1.id == self.currentUser.id || chat?.user2.id == self.currentUser.id{
                self.chats.append(chat!)
                self.friendsListTableView.insertRows(at: [IndexPath(row: self.chats.count-1, section: 0)], with: .automatic)
            }
            
        }
    }
    
    func configViews(){
        friendsListTableView.register(friendCellNib, forCellReuseIdentifier: friendCellReuseId)
        setupNavBar()
    }
    
    func setCurrentUser(){
        let phoneNumber = UserDefaults.standard.value(forKey: "phoneNumber")
        let searchRef = ref.child("users").queryOrdered(byChild: "phoneNumber").queryEqual(toValue: phoneNumber!)
        searchRef.observe(.value) { (snapshot) in
            if snapshot.value == nil{
                print("Current user not found")
                return
            }
            let userData = (snapshot.value! as! [String:Any]).first?.value
            let user = try? FirebaseDecoder().decode(User.self, from: userData!)
            self.currentUser = user!
            print("Current user found!")
        }
    }
    
    func setupNavBar(){
        navigationItem.title = "Chats"
        self.navigationController?.navigationBar.tintColor = .white
//        self.navigationController?.navigationBar.backgroundColor = .darkGray
        self.navigationController?.navigationBar.prefersLargeTitles = true
        let newChatBarButton = UIBarButtonItem(image:#imageLiteral(resourceName: "+") , style: .done, target: self, action:#selector(composeChatButtonTapped) )
        newChatBarButton.tintColor = UIColor(red: 233.0 / 255.0, green: 69.0 / 255.0, blue: 126.0 / 255.0, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = .black
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        self.navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationItem.rightBarButtonItem = newChatBarButton
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    @objc func composeChatButtonTapped(){
        let composeChatVC = ComposeNewChatViewController()
        composeChatVC.currentUser = self.currentUser
        self.navigationController?.pushViewController(composeChatVC, animated: true)
    }
}

extension FriendsViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: friendCellReuseId,for: indexPath) as! FriendsListTableViewCell
        if (currentUser.phoneNumber == chats[indexPath.row].user1.phoneNumber){
            cell.profileName.text! = chats[indexPath.row].user2.phoneNumber
        }else{
             cell.profileName.text! = chats[indexPath.row].user1.phoneNumber
        }
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(tableView.frame.height/7)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chatVC = ChatViewController()
        chatVC.currentUser = self.currentUser
        chatVC.currentChat = self.chats[indexPath.row]
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
}


