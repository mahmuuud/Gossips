//
//  AuthViewController.swift
//  Gossips
//
//  Created by mahmoud mohamed on 7/7/19.
//  Copyright © 2019 Robusta. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import CodableFirebase

class AuthViewController: UIViewController {
    
    @IBOutlet weak var verificationCodeTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    var verificationId:String!
    var ref:DatabaseReference!
    var currentUser:User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        configViews()
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKey))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func configViews(){
        verificationCodeTextField.delegate = self
        phoneNumberTextField.layer.cornerRadius = 5
        verificationCodeTextField.layer.cornerRadius = 5
        verifyButton.layer.cornerRadius = 5
        setupNavBar()
    }
    @objc func dismissKey(){
        view.endEditing(true)
    }
    func setupNavBar(){
        navigationItem.title = "Enter your Phone"
        self.navigationController?.navigationBar.backItem?.hidesBackButton = true
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.barTintColor = .black
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        self.navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        self.navigationController?.navigationBar.barStyle = .black
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumberTextField.text!, uiDelegate: nil) {[unowned self] (verificationId, error) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            print(verificationId!,"🚨")
            DispatchQueue.main.async {
                self.verificationId = verificationId
                self.verificationCodeTextField.isEnabled = true
            }
        }
    }
    
    func authenticate(verificationId:String,verificationCode:String){
        print(verificationCode)
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: verificationCode)
        Auth.auth().signIn(with: credential) { (dataResult, error) in
            if error != nil{
                print("Error: ",error!.localizedDescription)
                return
            }
            UserDefaults.standard.set(self.phoneNumberTextField.text!, forKey: "phoneNumber")
            self.currentUser = User(id:  UUID().uuidString, phoneNumber: self.phoneNumberTextField.text!)
            DispatchQueue.main.async {
                let friendsListVC = FriendsViewController()
                friendsListVC.currentUser = self.currentUser
                self.navigationController?.pushViewController(friendsListVC, animated: true)
             
            }
//            var userData=["id":self.currentUser.id]
//            userData["phoneNumber"] = self.phoneNumberTextField.text!
//            self.ref.child("users").childByAutoId().setValue(userData)
            do{
                print(self.currentUser!)
                let currentUserJson = try FirebaseEncoder().encode(self.currentUser)
                self.ref.child("users").childByAutoId().setValue(currentUserJson)
            }

            catch{
                print("error encoding user🌑")
            }
            
            print("Authenticated 🌕")
        }
    }
    
}

extension AuthViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("entered")
        if string == " "{
            return false
        }
        if textField.text!.count + string.count == 6 && string != ""{
            print("Authenticating")
            let verificationCode = textField.text! + string
            authenticate(verificationId: self.verificationId, verificationCode: verificationCode)
        }
        return true
    }
}
