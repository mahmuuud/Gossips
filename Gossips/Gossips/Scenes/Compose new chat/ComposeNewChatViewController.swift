//
//  ComposeNewChatViewController.swift
//  Gossips
//
//  Created by mahmoud mohamed on 7/8/19.
//  Copyright © 2019 Robusta. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase

class ComposeNewChatViewController: UIViewController {
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    var ref:DatabaseReference!
    var currentUser:User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        configViews()
    }
    
    func configViews(){
        setupNavBar()
    }
    
    func setupNavBar(){
        navigationItem.title = "Compose new chat"
        //        self.navigationController?.navigationBar.backgroundColor = .darkGray
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.barTintColor = .black
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        self.navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        self.navigationController?.navigationBar.barStyle = .black
    }


    @IBAction func nextButtonTapped(_ sender: Any) {
        let searchRef = ref.child("users").queryOrdered(byChild: "phoneNumber").queryEqual(toValue: phoneNumberTextField.text)
        searchRef.observe(.value) { (snapshot) in
            if snapshot.value is NSNull{
                self.presentError(title: "User not found", message: "please try a different number.")
                return
            }
            let userData = (snapshot.value! as? [String:Any])?.first?.value
            let user = try? FirebaseDecoder().decode(User.self, from: userData!)
            let chat = Chat(id: UUID().uuidString, user1:self.currentUser , user2: user!)
            let chatJson = try? FirebaseEncoder().encode(chat)
            self.ref.child("chats").childByAutoId().setValue(chatJson)
            DispatchQueue.main.async {
                //let chatVC = ChatViewController()
                //self.navigationController?.pushViewController(chatVC, animated: true)
                self.navigationController?.popViewController(animated: true)
            }
            print("user found: \(user!)")
        }
    }
    
    func presentError(title:String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert,animated: true)
    }
    
}
