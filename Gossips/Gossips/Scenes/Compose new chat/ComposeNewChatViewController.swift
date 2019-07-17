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
import ContactsUI
class ComposeNewChatViewController: UIViewController {
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var pickContacts: UIButton!
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
        self.navigationController?.navigationBar.isTranslucent = false
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
    
    @IBAction func picked(_ sender: Any) {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys =
            [CNContactGivenNameKey
                , CNContactPhoneNumbersKey]
        self.present(contactPicker, animated: true, completion: nil)
    }
    
}
extension ComposeNewChatViewController:CNContactPickerDelegate{
    
    
    func contactPicker(_ picker: CNContactPickerViewController,
                       didSelect contactProperty: CNContactProperty) {
        
    }
    
    func contactPicker(_ picker: CNContactPickerViewController,didSelect contact: CNContact) {
        
            let userName:String = contact.givenName
            let userPhoneNumbers:[CNLabeledValue<CNPhoneNumber>] = contact.phoneNumbers
            let firstPhoneNumber:CNPhoneNumber = userPhoneNumbers[0].value
            let primaryPhoneNumberStr:String = firstPhoneNumber.stringValue
            print(primaryPhoneNumberStr)
            
           phoneNumberTextField.text="+2"+primaryPhoneNumberStr
        
     
        
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        
    }
}
